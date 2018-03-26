sc->period = period;
sc->head = 0;
sc->tail = 0;
sc->max = max_refills;
HEAD(sc).amount = budget;
HEAD(sc).time = current_time;
