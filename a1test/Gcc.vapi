/* Gcc.vapi - provides access to GCC's predefined macros */
namespace Gcc {
    [CCode (cname = "__DATE__")]
    static string date;
    [CCode (cname = "__TIME__")]
    static string time;
}
