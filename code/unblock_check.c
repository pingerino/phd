if (HEAD(sc).time < current_time + kernel_wcet) {
  /* advance earliest activation time to now */
  HEAD(sc).time = NODE_STATE(ksCurTime);

  /* merge available replenishments */
  while (sc.head != sc.tail) {
    ticks_t amount = HEAD(sc).amount;
    if (INDEX(sc, NEXT(sc, sc->head)).time <= current_time + amount) {
      POP(sc);
      HEAD(sc).amount += amount;
      HEAD(sc).time = NODE_STATE(ksCurTime);
    } else {
      break;
    }
  }
}
