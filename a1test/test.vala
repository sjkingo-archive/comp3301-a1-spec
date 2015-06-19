static void signal_handler(int signum) {
    if (signum == Posix.SIGALRM) {
        stderr.printf("Test timeout... check the Pth library, seems like a bug\n");
    } else if (signum == Posix.SIGSEGV) {
        stderr.printf("Test program received a SIGSEGV, this is probably a bug in the Pth library ");
        if (lib_path == null) {
            stderr.printf("(LD_LIBRARY_PATH not set)\n");
        } else {
            stderr.printf("(LD_LIBRARY_PATH = %s)\n", lib_path);
        }
        stderr.printf("FAIL\n");
    }

    Posix.exit(4);
}

void run_tests(TestInput test) {
    Timer timer = new Timer();

    /* kill the test program after 3 times the lifetime */
    Posix.signal(Posix.SIGALRM, signal_handler);
    Posix.alarm(test.lifetime * 3);

    /* handle segfaults gracefully */
    Posix.signal(Posix.SIGSEGV, signal_handler);

    Pth.begin();
    stdout.printf("\n");
    stdout.printf("Running test (wait %d seconds)...\n", test.lifetime);

    timer.start();

    /* fire up each thread */
    Pth.Thread[] threads = new Pth.Thread[test.n];
    for (int i = 0; i < test.n; i++) {
        var tcb = test.get_thread(i);
        /* set the thread priority */
        int p;
        var attr = new Pth.Attribute();
        attr.set(Pth.Attribute.Type.PRIO, tcb.prio);
        attr.get(Pth.Attribute.Type.PRIO, out p);
        if (p != tcb.prio) {
            stderr.printf("Failed to set priority on t_%d\n", tcb.id);
        }

        threads[tcb.id] = new Pth.Thread(attr, thread_func, tcb);
    }

    /* sleep the main thread until end of test lifetime */
    Pth.sleep(test.lifetime);
    timer.stop();

    stdout.printf("Lifetime reached, test over (after %.2f s)\n", timer.elapsed(null));
    stdout.printf("For a test to pass, the thread's actual runtime must be within +- 5%% of its target\n");
    stdout.printf("\n");

    /* kill off all of the threads and print their runtimes */
    double total_p = 0;
    int total_s = 0;
    for (int i = 0; i < test.n; i++) {
        var tcb = test.get_thread(i);
        Pth.Thread t = threads[tcb.id];
        t.cancel();

        double actual_p = tcb.actual_as_perc(timer.elapsed(null));
        total_p += actual_p;
        total_s += (int)tcb.actual;

        /* we allow +- 5% */
        if (actual_p < (tcb.target - 5) || actual_p > (tcb.target + 5)) {
            stdout.printf("t_%d result: FAIL\n", tcb.id);
        } else {
            stdout.printf("t_%d result: PASS\n", tcb.id);
        }

        stdout.printf("  actual = %.2f%% (%.2f s)\n", actual_p, tcb.actual);
        stdout.printf("  target = %.2f%% (%.2f s)\n", tcb.target, 
                test.lifetime * (tcb.target/100));

        double dev = actual_p - tcb.target;
        int dev_rounded = (int)GLib.Math.round(dev);
        if (dev_rounded > 0) {
            stdout.printf("  (%.2f%% over target)\n", dev);
        } else if (dev_rounded < 0) {
            stdout.printf("  (%.2f%% under target)\n", Posix.fabs(dev));
        } else {
            stdout.printf("  (on target)\n");
        }
    }

    /* if this fails, then we have a bug in the time accounting */
    assert(total_p >= 99 || total_p <= 101);
    //assert(total_s >= (test.lifetime - 1) && total_s <= (test.lifetime + 1));

    Pth.end();
}
