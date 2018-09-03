/* first deal with the remaining budget of the current replenishment */
ticks_t remnant = HEAD(sc).amount - usage;
refill_t new = (refill_t) {
  .amount = usage, .time = HEAD(sc).time + sc->scPeriod
};
if (SIZE(sc) == sc->max || remnant < MIN_BUDGET) {
  /* merge remnant with next replenishment - either it's too small
   * or we're out of space */
  if (sc->head == sc->tail) {
    /* update inplace */
    new.amount += remnant;
    HEAD(sc) = new;
  } else {
    POP(sc);
    HEAD(sc).amount += remnant;
    schedule_used(sc, new);
  }
} else {
  /* split the head refill  */
  HEAD(sc).amount = remnant;
  schedule_used(sc, new);
}
