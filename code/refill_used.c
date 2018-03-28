if (new.amount < MIN_BUDGET && sc->head != sc->tail) {
  /* used amount is too small - merge with last and delay */
  TAIL(sc).amount += new.amount;
  TAIL(sc).time = MAX(new.time, TAIL(sc).time);
} else if (new.time <= TAIL(sc).time) {
  TAIL(sc).amount += new.amount;
} else {
  sc->tail = NEXT(sc, sc->tail);
  TAIL(sc) = new;
}
