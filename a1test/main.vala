/* Changelog
 * 1.0
 *    - Initial version
 * 1.1
 *    - Fixed rounding errors in PASS/FAIL ("0.00% below target")
 *    - Added newline after test results so when scripting the separation 
 *        between tests can be seen easily
 *    - Catch SIGSEGV and try and exit gracefully
 *    - Added uname -a output to -v
 *    - Rearranged main.vala
 * 1.2
 *    - Added -t flag to output timing information
 *    - Moved thread-related things to thread.vala
 */

/* Version of this test program */
double version = 1.2;

/* Expected version of the Pth library. The test program will fail to run if
 * it is not linked against this version.
 */
long expected_ver = 0x200207; /* 2.0.7 */

/* Value of the LD_LIBRARY_PATH env variable, or null if not set */
string lib_path;

/* Flag to print timing information to screen (-t argument) */
bool print_timing = false;

static string? system_uname() {
    string u;

    try {
        GLib.Process.spawn_sync(null, {"/bin/uname", "-a", null}, 
                null, GLib.SpawnFlags.STDERR_TO_DEV_NULL, null, 
                out u, null, null);
    } catch (GLib.SpawnError e) {
        stderr.printf("Failed to execute uname -a: %s\n", e.message);
        u = null;
    }

    return u;
}

static void print_version() {
    stdout.printf("COMP3301 A1 tester v%.1f\n", version);
    stdout.printf("Written by Sam Kingston, 2010\n");
    stdout.printf("Compiled at %s %s\n", Gcc.date, Gcc.time);
    stdout.printf("Linked against Pth version 0x%lx\n", Pth.version());
    stdout.printf("\n");

    if (lib_path == null) {
        stdout.printf("LD_LIBRARY_PATH not set\n");
    } else {
        stdout.printf("LD_LIBRARY_PATH = %s\n", lib_path);
    }

    string uname = system_uname();
    if (uname != null) {
         stdout.printf("uname -a: %s", uname); /* already has \n */
    }
}

static void usage_error(string[] args) {
    stderr.printf("Usage: %s [-t] test-case\n", args[0]);
    stderr.printf("       %s -v\n", args[0]);
    stderr.printf("Set LD_LIBRARY_PATH to use a specific version of Pth (and use -v to verify it)\n");
    Posix.exit(1);
}

static TestInput prepare_for_tests(string filename) {
    /* check the Pth version first */
    if (Pth.version() != expected_ver) {
        stderr.printf("You are running the wrong version of Pth\n");
        Posix.exit(5);
    }

    /* if LD_LIBRARY_PATH is not set, it is possible the user is using
     * the wrong library
     */
    if (lib_path == null) {
        stderr.printf("LD_LIBRARY_PATH is not set, are you sure this is what you want?\n");
    }

    TestInput input = null;
    try {
        input = parse_test_file(filename);
    } catch (TestInputError e) {
        stderr.printf("Error parsing input file '%s': %s\n", filename, 
                e.message);
        Posix.exit(2);
    }

    return input;
}

static void test_runner(string filename) {
    var input = prepare_for_tests(filename);
    input.dump_data();
    run_tests(input);
    stdout.printf("--\n");
}

public int main(string[] args) {
    lib_path = GLib.Environment.get_variable("LD_LIBRARY_PATH");

    /* do some silly arguments checking.. really needs getopt or equiv here */
    if (args.length == 2) {
        if (args[1] == "-v") {
            print_version();
        } else {
            test_runner(args[1]);
        }
    } else if (args.length == 3) {
        if (args[1] == "-t") {
            print_timing = true;
            stderr.printf("Warning enabling -t may cause test results to be bloated (watch for false test failures)\n");
            test_runner(args[2]);
        } else {
            usage_error(args);
        }
    } else {
        usage_error(args);
    }

    return 0;
}
