/* truncate to size 1 */
INDEX(sc, 0) = HEAD(sc);
sc->head = 0;
sc->tail = sc->head;
sc->max = new_max_refills;
sc->period = new_period;

if (HEAD(sc).time <= (current_time + kernel_wcet))
  HEAD(sc).time = current_time;

if (HEAD(sc).amount >= new_budget) {
  HEAD(sc).amount = new_budget;
} else { 
  /* schedule excess amount */
  sc->tail = NEXT(sc, new);
  TAIL(sc).amount = (new_budget - HEAD(sc).amount);
  TAIL(sc).time = HEAD(sc).rTime + new_period;
}
