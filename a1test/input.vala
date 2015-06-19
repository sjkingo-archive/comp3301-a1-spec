errordomain TestInputError {
    SYNTAX_ERROR,
    VALUE_ERROR,
    INVALID_FILE
}

class TestInput : GLib.Object {
    private string filename;
    private ThreadControlBlock[] threads;

    public int lifetime {
        get;
        private set;
    }

    public int n {
        get { return threads.length; }
    }

    public TestInput(string filename, int lifetime) {
        this.filename = filename;
        this.lifetime = lifetime;
        this.threads = {};
    }

    public void new_thread(int i, int prio, int greedy) {
        var b = new ThreadControlBlock(i, prio, greedy);
        this.threads += b;
    }

    public ThreadControlBlock get_thread(int i) {
        return this.threads[i];
    }        

    public void dump_data() {
        stdout.printf("%s:\n", this.filename);
        stdout.printf("  lifetime = %d s\n", this.lifetime);
        stdout.printf("  n = %d\n", this.n);
        for (int i = 0; i < this.threads.length; i++) {
            var b = this.threads[i];
            stdout.printf("  t_%d: prio = %d, greedy = %d, target = %.2f%%\n", 
                    i, b.prio, b.greedy, b.target);
        }
    }

    public void update_targets() {
        /* compute sum_j(P_j + 1) */
        int sum = 0;
        for (int i = 0; i < this.n; i++) {
            sum += this.threads[i].prio + 1;
        }

        /* compute target */
        for (int i = 0; i < this.n; i++) {
            var b = this.threads[i];
            b.target = ((b.prio + 1) / (double)sum) * 100;
        }
    }
}

TestInput? parse_test_file(string filename) throws TestInputError {
    string[] lines = {};
    var file = File.new_for_path(filename);

    try {
        var stream = new DataInputStream(file.read(null));
        string line;
        while ((line = stream.read_line(null, null)) != null) {
            if (line[0] == '#') {
                continue;
            }
            lines += line;
        }
    } catch (Error e) {
        throw new TestInputError.INVALID_FILE(e.message);
    }

    TestInput test = null;

    for (int i = 0; i < lines.length; i++) {
        string line = lines[i];
        if (i == 0) {
            /* lifetime */
            string[] fields = line.split(" ");
            if (fields.length != 1) {
                throw new TestInputError.SYNTAX_ERROR("line 0 should only have 1 field");
            }

            int lifetime = line.to_int();
            if (lifetime <= 0) {
                throw new TestInputError.VALUE_ERROR("line %d: lifetime <= 0", i);
            }
            test = new TestInput(filename, lifetime);
        } else {
            /* thread control line: (prio, greedy) all in doubles */
            string[] fields = line.split(" ");
            if (fields.length != 2) {
                throw new TestInputError.SYNTAX_ERROR("line %d does not have 2 fields", i);
            }

            int prio = fields[0].to_int();
            if (prio < 0) {
                throw new TestInputError.VALUE_ERROR("line %d: prio field < 0", i);
            }

            int greedy = fields[1].to_int();
            if (greedy < 0 || greedy > 100) {
                throw new TestInputError.VALUE_ERROR("line %d: greedy field not in range [0..100]", i);
            }
            if (greedy == 0) {
                stderr.printf("Warning: line %d has greedy = 0; this thread will probably never account any time\n", i);
            }

            test.new_thread(i-1, prio, greedy);
        }
    }

    if (test == null) {
        throw new TestInputError.SYNTAX_ERROR("empty file?");
    }

    if (test.n == 0) {
        throw new TestInputError.SYNTAX_ERROR("no threads specified");
    }

    /* update the target runtimes */
    test.update_targets();

    return test;
}
