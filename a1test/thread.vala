class ThreadControlBlock : GLib.Object {
    public unowned int id {
        get;
        private set;
    }

    public int prio {
        get;
        private set;
    }

    public int greedy {
        get;
        private set;
    }

    public double target;

    private double time_spent;
    public double actual {
        get { return time_spent; }
    }

    public ThreadControlBlock(int id, int prio, int greedy) {
        this.id = id;
        this.prio = prio;
        this.greedy = greedy;
        this.target = 0;
        this.time_spent = 0;
    }

    public void account(double time) {
        this.time_spent += time;
        if (print_timing) {
            stderr.printf("t_%d spent %.2f s before yielding (cumulative %.2f s)\n", 
                    this.id, time, this.time_spent);
        }
    }

    public double actual_as_perc(double elapsed_time) {
        return (this.time_spent / elapsed_time) * 100;
    }
}

void *thread_func(void *arg)
{
    var thread = (ThreadControlBlock)arg;
    while (true) {
        Timer timer = new Timer();

        timer.start();
        for (uint i = 0; i < 1000000 * thread.greedy; i++) {
            /* nop */
        }
        timer.stop();

        thread.account(timer.elapsed(null));
        Pth.yield();
    }
}

