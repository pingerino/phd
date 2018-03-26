while(true) {
  uint64_t time = get_time();
  
  /* release any threads */
  release_top = NULL;
  while (!empty(release_queue) && head(release_queue)->weight < time) {
    /* implict deadlines */
    head->weight = time + head->period;
    push(deadline_queue, release_top);
    release_top = pop(release_queue);
  }

  if (release_top != NULL) {
    /* set preemption timeout */
    set_timeout(release_top->weight);
  }

  /* pick a thread */
  current_thread = head(deadline_queue);
  if (current_thread != NULL) {
    if (!current_thread->resume_cap_set) {
      /* current was preempted - put it at the head of its scheduling queue */
      seL4_SchedContext_YieldTo(current->sc);
      info = seL4_Recv(endpoint, &badge, current->resume_cap);
    } else {
      /* current is waiting for us to reply - it either timeout faulted, or called us to 
       * cooperatively schedule */
      current_thread->resume_cap_set = false;
      info = seL4_ReplyRecv(endpoint, info, &badge, current->resume_cap);
    }
  } else {
    /* noone to schedule */
    info = seL4_Wait(data->endpoint, &badge);
  }

  /* here we wake from an IPC or interrupt */
  if (badge >= top_thread_id) {
    /* it's a preemption interrupt */
    handle_interrupt();
  } else {
    /* it's an IPC - must be from current */
    pop(deadline_tree);
    push(release_tree, current);
    prev_thread = current;
    prev_thread->resume_cap_set = true;
  }
}
