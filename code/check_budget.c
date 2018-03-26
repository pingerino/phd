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
    if (unlikely(usage > HEAD(sc).rAmount)) {
        return 0;
    }

    return HEAD(sc).rAmount - usage;
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
    return HEAD(sc).rTime <= (NODE_STATE(ksCurTime) + getKernelWcetTicks());
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
    refill_t refill = HEAD(sc);
    sc->scRefillHead = refill_next(sc, sc->scRefillHead);
    return refill;
}

/* add item to tail of refill queue */
static inline void
refill_add_tail(sched_context_t *sc, refill_t refill)
{
    word_t new_tail = refill_next(sc, sc->scRefillTail);
    sc->scRefillTail = new_tail;
    TAIL(sc) = refill;
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

void schedule_used(sched_context_t *sc, refill_t new)
{
    if (new.amount < MIN_BUDGET && sc->head != sc->tail) {
        /* used amount is to small - merge with last and delay */
        TAIL(sc).amount += new.amount;
        TAIL(sc).time = MAX(new.time, TAIL(sc).time);
    } else if (new.rTime <= TAIL(sc).rTime) {
        TAIL(sc).amount += new.amount;
    } else {
        sc->tail = refill_next(sc->tail);
        TAIL(sc) = new;
    }
}
void refill_budget_check(sched_context_t *sc, ticks_t usage, ticks_t capacity)
{
    if (capacity == 0) {
        while (HEAD(sc).rAmount <= usage) {
            /* exhaust and schedule replenishment */
            usage -= HEAD(sc).rAmount;
            if (refill_single(sc)) {
                /* update in place */
                HEAD(sc).rTime += sc->scPeriod;
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
            HEAD(sc).rTime += usage;
            /* merge front two replenishments if times overlap */
            if (!refill_single(sc) &&
                    HEAD(sc).rTime + HEAD(sc).rAmount >=
                    INDEX(sc, refill_next(sc, sc->scRefillHead)).rTime) {

                refill_t refill = refill_pop_head(sc);
                HEAD(sc).rAmount += refill.rAmount;
                HEAD(sc).rTime = refill.rTime;
            }
        }
    }

    if (refill_capacity(sc, usage) > 0 && refill_ready(sc))
        refill_split_check(sc, usage);

    /* ensure the refill head is sufficient, such that when we wake in awaken,
     * there is enough budget to run */
    while (HEAD(sc).rAmount < MIN_BUDGET || refill_full(sc)) {
        refill_t refill = refill_pop_head(sc);
        HEAD(sc).rAmount += refill.rAmount;
    }
}
void
refill_split_check(sched_context_t *sc, ticks_t usage)
{
    /* first deal with the remaining budget of the current replenishment */
    ticks_t remnant = HEAD(sc).rAmount - usage;

    /* set up a new replenishment structure */
    refill_t new = (refill_t) {
        .rAmount = usage, .rTime = HEAD(sc).rTime + sc->scPeriod
    };

    if (refill_size(sc) == sc->scRefillMax || remnant < MIN_BUDGET) {
        /* merge remnant with next replenishment - either it's too small
         * or we're out of space */
        if (refill_single(sc)) {
            /* update inplace */
            new.rAmount += remnant;
            HEAD(sc) = new;
        } else {
            refill_pop_head(sc);
            HEAD(sc).rAmount += remnant;
            schedule_used(sc, new);
        }
    } else  {
        /* split the head refill  */
        HEAD(sc).rAmount = remnant;
        HEAD(sc).rTime += usage;
        schedule_used(sc, new);
    }
}
