/* This header presents the interface for sporadic servers,
 * implemented according to Stankcovich et. al in
 * "Defects of the POSIX Spoardic Server and How to correct them",
 * although without the priority management and enforcing a minimum budget.
 */
/* functions to manage the circular buffer of
 * sporadic budget replenishments (refills for short).
 *
 * The circular buffer always has at least one item in it.
 *
 * Items are appended at the tail (the back) and
 * removed from the head (the front). Below is
 * an example of a queue with 4 items (h = head, t = tail, x = item, [] = slot)
 * and max size 8.
 *
 * [][h][x][x][t][][][]
 *
 * and another example of a queue with 5 items
 *
 * [x][t][][][][h][x][x]
 *
 * The queue has a minimum size of 1, so it is possible that h == t.
 *
 * The queue is implemented as head + tail rather than head + size as
 * we cannot use the mod operator on all architectures without accessing
 * the fpu or implementing divide.
 */

/* To do an operation in the kernel, the thread must have
 * at least this much budget - see comment on refill_sufficient */
#define MIN_BUDGET_US (2u * getKernelWcetUs())
#define MIN_BUDGET    (2u * getKernelWcetTicks())

/* Short hand for accessing refill queue items */
#define REFILL_INDEX(sc, index) (((refill_t *) ((sched_context_t *)(sc) + sizeof(sched_context_t)))[index])
#define REFILL_HEAD(sc) REFILL_INDEX((sc), (sc)->scRefillHead)
#define REFILL_TAIL(sc) REFILL_INDEX((sc), (sc)->scRefillTail)

/* return the amount of refills we can fit in this scheduling context */
static inline word_t
refill_absolute_max(cap_t sc_cap)
{
    return (BIT(cap_sched_context_cap_get_capSCSizeBits(sc_cap)) - sizeof(sched_context_t)) / sizeof(refill_t);
}

/* Return the amount of items currently in the refill queue */
static inline word_t
refill_size(sched_context_t *sc)
{
    if (sc->scRefillHead <= sc->scRefillTail) {
        return (sc->scRefillTail - sc->scRefillHead + 1u);
    }
    return sc->scRefillTail + 1u + (sc->scRefillMax - sc->scRefillHead);
}

static inline bool_t
refill_full(sched_context_t *sc)
{
    return refill_size(sc) == sc->scRefillMax;
}

static inline bool_t
refill_single(sched_context_t *sc)
{
    return sc->scRefillHead == sc->scRefillTail;
}

/* Return the amount of budget this scheduling context
 * has available if usage is charged to it. */
static inline ticks_t
refill_capacity(sched_context_t *sc, ticks_t usage)
{
    if (unlikely(usage > REFILL_HEAD(sc).rAmount)) {
        return 0;
    }

    return REFILL_HEAD(sc).rAmount - usage;
}

/*
 * Return true if the head refill has sufficient capacity
 * to enter and exit the kernel after usage is charged to it.
 */
static inline bool_t
refill_sufficient(sched_context_t *sc, ticks_t usage)
{
    return refill_capacity(sc, usage) >= MIN_BUDGET;
}

/*
 * Return true if the refill is eligible to be used.
 * This indicates if the thread bound to the sc can be placed
 * into the scheduler, otherwise it needs to go into the release queue
 * to wait.
 */
static inline bool_t
refill_ready(sched_context_t *sc)
{
    return REFILL_HEAD(sc).rTime <= (NODE_STATE(ksCurTime) + getKernelWcetTicks());
}

/* return the index of the next item in the refill queue */
static inline word_t
refill_next(sched_context_t *sc, word_t index)
{
    return (index == sc->scRefillMax - 1u) ? (0) : index + 1u;
}

/* pop head of refill queue */
static inline refill_t
refill_pop_head(sched_context_t *sc)
{
    UNUSED word_t prev_size = refill_size(sc);
    refill_t refill = REFILL_HEAD(sc);
    sc->scRefillHead = refill_next(sc, sc->scRefillHead);
    return refill;
}

/* add item to tail of refill queue */
static inline void
refill_add_tail(sched_context_t *sc, refill_t refill)
{
    word_t new_tail = refill_next(sc, sc->scRefillTail);
    sc->scRefillTail = new_tail;
    REFILL_TAIL(sc) = refill;
}

static inline void
maybe_add_empty_tail(sched_context_t *sc)
{
    if (isRoundRobin(sc)) {
        /* add an empty refill - we track the used up time here */
        refill_t empty_tail = { .rTime = NODE_STATE(ksCurTime)};
        refill_add_tail(sc, empty_tail);
    }
}

/* Create a new refill in a non-active sc */
void
refill_new(sched_context_t *sc, word_t max_refills, ticks_t budget, ticks_t period)
{
    sc->scPeriod = period;
    sc->scRefillHead = 0;
    sc->scRefillTail = 0;
    sc->scRefillMax = max_refills;
    /* full budget available */
    REFILL_HEAD(sc).rAmount = budget;
    /* budget can be used from now */
    REFILL_HEAD(sc).rTime = NODE_STATE(ksCurTime);
    maybe_add_empty_tail(sc);
}

/* Update refills in an active sc without violating bandwidth constraints */
void
refill_update(sched_context_t *sc, ticks_t new_period, ticks_t new_budget, word_t new_max_refills)
{

    /* this is called on an active thread. We want to preserve the sliding window constraint -
     * so over new_period, new_budget should not be exceeded even temporarily */

    /* move the head refill to the start of the list - it's ok as we're going to truncate the
     * list to size 1 - and this way we can't be in an invalid list position once new_max_refills
     * is updated */
    REFILL_INDEX(sc, 0) = REFILL_HEAD(sc);
    sc->scRefillHead = 0;
    /* truncate refill list to size 1 */
    sc->scRefillTail = sc->scRefillHead;
    /* update max refills */
    sc->scRefillMax = new_max_refills;
    /* update period */
    sc->scPeriod = new_period;

    if (refill_ready(sc)) {
        REFILL_HEAD(sc).rTime = NODE_STATE(ksCurTime);
    }

    if (REFILL_HEAD(sc).rAmount >= new_budget) {
        /* if the heads budget exceeds the new budget just trim it */
        REFILL_HEAD(sc).rAmount = new_budget;
        maybe_add_empty_tail(sc);
    } else {
        /* otherwise schedule the rest for the next period */
        refill_t new = { .rAmount = (new_budget - REFILL_HEAD(sc).rAmount),
                         .rTime = REFILL_HEAD(sc).rTime + new_period
                       };
        refill_add_tail(sc, new);
    }
}

static inline void
schedule_used(sched_context_t *sc, refill_t new)
{
    /* schedule the used amount */
    if (new.rAmount < MIN_BUDGET && !refill_single(sc)) {
        /* used amount is to small - merge with last and delay */
        REFILL_TAIL(sc).rAmount += new.rAmount;
        REFILL_TAIL(sc).rTime = MAX(new.rTime, REFILL_TAIL(sc).rTime);
    } else if (new.rTime <= REFILL_TAIL(sc).rTime) {
        REFILL_TAIL(sc).rAmount += new.rAmount;
    } else {
        refill_add_tail(sc, new);
    }
}

/* Charge the head refill its entire amount.
 *
 * `used` amount from its current replenishment without
 * depleting the budget, i.e refill_expired returns false.
 */
void
refill_budget_check(sched_context_t *sc, ticks_t usage, ticks_t capacity)
{
    if (capacity == 0) {
        while (REFILL_HEAD(sc).rAmount <= usage) {
            /* exhaust and schedule replenishment */
            usage -= REFILL_HEAD(sc).rAmount;
            if (refill_single(sc)) {
                /* update in place */
                REFILL_HEAD(sc).rTime += sc->scPeriod;
            } else {
                refill_t old_head = refill_pop_head(sc);
                old_head.rTime = old_head.rTime + sc->scPeriod;
                schedule_used(sc, old_head);
            }
        }

        /* budget overrun */
        if (usage > 0) {
            /* budget reduced when calculating capacity */
            /* due to overrun delay next replenishment */
            REFILL_HEAD(sc).rTime += usage;
            /* merge front two replenishments if times overlap */
            if (!refill_single(sc) &&
                    REFILL_HEAD(sc).rTime + REFILL_HEAD(sc).rAmount >=
                    REFILL_INDEX(sc, refill_next(sc, sc->scRefillHead)).rTime) {

                refill_t refill = refill_pop_head(sc);
                REFILL_HEAD(sc).rAmount += refill.rAmount;
                REFILL_HEAD(sc).rTime = refill.rTime;
            }
        }
    }

    capacity = refill_capacity(sc, usage);
    if (capacity > 0 && refill_ready(sc)) {
        refill_split_check(sc, usage);
    }

    /* ensure the refill head is sufficient, such that when we wake in awaken,
     * there is enough budget to run */
    while (REFILL_HEAD(sc).rAmount < MIN_BUDGET || refill_full(sc)) {
        refill_t refill = refill_pop_head(sc);
        REFILL_HEAD(sc).rAmount += refill.rAmount;
        /* this loop is guaranteed to terminate as the sum of
         * rAmount in a refill must be >= MIN_BUDGET */
    }
}

/*
 * Charge a scheduling context `used` amount from its
 * current refill. This will split the refill, leaving whatever is
 * left over at the head of the refill.
 */
void
refill_split_check(sched_context_t *sc, ticks_t usage)
{
    /* first deal with the remaining budget of the current replenishment */
    ticks_t remnant = REFILL_HEAD(sc).rAmount - usage;

    /* set up a new replenishment structure */
    refill_t new = (refill_t) {
        .rAmount = usage, .rTime = REFILL_HEAD(sc).rTime + sc->scPeriod
    };

    if (refill_size(sc) == sc->scRefillMax || remnant < MIN_BUDGET) {
        /* merge remnant with next replenishment - either it's too small
         * or we're out of space */
        if (refill_single(sc)) {
            /* update inplace */
            new.rAmount += remnant;
            REFILL_HEAD(sc) = new;
        } else {
            refill_pop_head(sc);
            REFILL_HEAD(sc).rAmount += remnant;
            schedule_used(sc, new);
        }
    } else  {
        /* split the head refill  */
        REFILL_HEAD(sc).rAmount = remnant;
        schedule_used(sc, new);
    }
}

/*
 * This is called when a thread is eligible to start running: it
 * iterates through the refills queue and merges any
 * refills that overlap.
 */
void
refill_unblock_check(sched_context_t *sc)
{
    if (isRoundRobin(sc)) {
        /* nothing to do */
        return;
    }

    /* advance earliest activation time to now */
    if (refill_ready(sc)) {
        REFILL_HEAD(sc).rTime = NODE_STATE(ksCurTime);
        NODE_STATE(ksReprogram) = true;

        /* merge available replenishments */
        while (!refill_single(sc)) {
            ticks_t amount = REFILL_HEAD(sc).rAmount;
            if (REFILL_INDEX(sc, refill_next(sc, sc->scRefillHead)).rTime <= NODE_STATE(ksCurTime) + amount) {
                refill_pop_head(sc);
                REFILL_HEAD(sc).rAmount += amount;
                REFILL_HEAD(sc).rTime = NODE_STATE(ksCurTime);
            } else {
                break;
            }
        }
    }
}
