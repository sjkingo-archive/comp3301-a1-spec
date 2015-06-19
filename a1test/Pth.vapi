/* Pth.vapi - bindings for the GNU Portable Threads library */

[CCode (cheader_filename = "pth.h")]

namespace Pth {
    [CCode (cname = "pth_init")]
    public int begin();
    [CCode (cname = "pth_kill")]
    public int end();
    [CCode (cname = "pth_sleep")]
    public uint sleep(uint seconds);
    [CCode (cname = "pth_yield")]
    public int yield(Thread? other=null);
    [CCode (cname = "pth_version")]
    public long version();

    [CCode (cname = "struct pth_st", ref_function = "", unref_function = "")]
    public class Thread : GLib.Object {
        [CCode (has_target = false, cname = "_start_func_t")]
        public delegate void *start_func_t(void *arg);
        [CCode (cname = "pth_spawn")]
        public Thread(Attribute attr, start_func_t func, void *arg);
        [CCode (cname = "pth_cancel")]
        public int cancel();
    }

    [CCode (cname = "struct pth_attr_st", ref_function = "", unref_function = "", free_function = "pth_attr_destroy")]
    public class Attribute : GLib.Object {
        [CCode (cname = "PTH_ATTR_DEFAULT")]
        public static Attribute DEFAULT;
        [CCode (cname = "pth_attr_new")]
        public Attribute();
        [CCode (cprefix = "PTH_ATTR_")]
        public enum Type {
            PRIO,
            NAME,
            JOINABLE,
            CANCEL_STATE,
            STACK_SIZE,
            STACK_ADDR,
            DISPATCHES
        }
        [CCode (cname = "pth_attr_set")]
        public int set(Type field, ...);
        [CCode (cname = "pth_attr_get")]
        public int get(Type field, ...);
    }
}
