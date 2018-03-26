if (capacity == 0) {
  while (HEAD(sc).amount <= usage) {
    /* exhaust and schedule replenishment */
    usage -= HEAD(sc).amount;
    if (sc->head == sc->tail) {
      /* update in place */
      HEAD(sc).time += sc->period;
    } else {
      refill_t old_head = POP(sc);
      old_head.time = old_head.time + sc->period;
      schedule_used(sc, old_head);
    }
  }

  /* budget overrun */
  if (usage > 0) {
    /* budget reduced when calculating capacity */
    /* due to overrun delay next replenishment */
    HEAD(sc).time += usage;
    /* merge front two replenishments if times overlap */
    if (sc->head != sc->tail &&
        HEAD(sc).time + HEAD(sc).amount >=
        INDEX(sc, NEXT(sc, sc->head)).time) {
      refill_t refill = POP(sc);
      HEAD(sc).amount += refill.amount;
      HEAD(sc).time = refill.time;
    }
  }
}
capacity = MAX(HEAD.amount - usage, 0);
if (capacity > 0 && refill_ready(sc))
  split_check(sc, usage);
/* ensure the refill head is sufficient to run */
while (HEAD(sc).amount < MIN_BUDGET || sc.head == sc.tail) {
  HEAD(sc).amount += POP(sc).amount;
}
