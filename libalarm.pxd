#for DBUS things
cdef union value:
    unsigned int u
    int i
    int b
    double d
    char *s

cdef extern from "string.h":
    ctypedef int size_t

cdef extern from "Python.h":
    object PyInt_FromLong(long value)
    object PyLong_FromLongLong(long long value)

cdef extern from "time.h":
    struct tm:
        int tm_sec
        int tm_min
        int tm_hour
        int tm_mday
        int tm_mon
        int tm_year
        int tm_wday
        int tm_yday
        int tm_isdst

    ctypedef int time_t

    time_t mktime(tm *)
    tm *localtime(time_t *)

cdef extern from "libalarm.h":

    ctypedef unsigned long uint32_t
    ctypedef unsigned long long uint64_t

    struct alarm_attr_t:
        pass

    struct alarm_action_t:
        unsigned int flags

    struct alarm_event_t:
        alarm_action_t *action_tab
        size_t action_cnt
        time_t alarm_time
        size_t recur_count
        size_t recurrence_cnt

    struct alarm_recur_t:
        uint64_t mask_min
        uint32_t mask_hour
        uint32_t mask_mday
        uint32_t mask_wday
        uint32_t mask_mon
        uint32_t special

    ctypedef int cookie_t

    # Enums

    cdef enum alarmactionflags:
        ALARM_ACTION_TYPE_NOP,
        ALARM_ACTION_TYPE_SNOOZE,
        ALARM_ACTION_TYPE_DBUS,
        ALARM_ACTION_TYPE_EXEC,
        ALARM_ACTION_TYPE_DISABLE,
        ALARM_ACTION_WHEN_QUEUED,
        ALARM_ACTION_WHEN_DELAYED,
        ALARM_ACTION_WHEN_TRIGGERED,
        ALARM_ACTION_WHEN_DISABLED,
        ALARM_ACTION_WHEN_RESPONDED,
        ALARM_ACTION_WHEN_DELETED,
        ALARM_ACTION_DBUS_USE_ACTIVATION,
        ALARM_ACTION_DBUS_USE_SYSTEMBUS,
        ALARM_ACTION_DBUS_ADD_COOKIE,
        ALARM_ACTION_EXEC_ADD_COOKIE,
        ALARM_ACTION_TYPE_MASK,
        ALARM_ACTION_WHEN_MASK

    cdef enum alarmrecurflags:
        ALARM_RECUR_MIN_DONTCARE,
        ALARM_RECUR_MIN_ALL,
        ALARM_RECUR_HOUR_DONTCARE,
        ALARM_RECUR_HOUR_ALL,

        ALARM_RECUR_MDAY_DONTCARE,
        ALARM_RECUR_MDAY_ALL,
        ALARM_RECUR_MDAY_EOM,
        ALARM_RECUR_WDAY_DONTCARE,

        ALARM_RECUR_WDAY_ALL,
        ALARM_RECUR_WDAY_SUN,
        ALARM_RECUR_WDAY_MON,
        ALARM_RECUR_WDAY_TUE,

        ALARM_RECUR_WDAY_WED,
        ALARM_RECUR_WDAY_THU,
        ALARM_RECUR_WDAY_FRI,
        ALARM_RECUR_WDAY_SAT,

        ALARM_RECUR_WDAY_MONFRI,
        ALARM_RECUR_WDAY_SATSUN,
        ALARM_RECUR_MON_DONTCARE,
        ALARM_RECUR_MON_ALL,

        ALARM_RECUR_MON_JAN,
        ALARM_RECUR_MON_FEB,
        ALARM_RECUR_MON_MAR,
        ALARM_RECUR_MON_APR,

        ALARM_RECUR_MON_MAY,
        ALARM_RECUR_MON_JUN,
        ALARM_RECUR_MON_JUL,
        ALARM_RECUR_MON_AUG,

        ALARM_RECUR_MON_SEP,
        ALARM_RECUR_MON_OCT,
        ALARM_RECUR_MON_NOW,
        ALARM_RECUR_MON_DEC,

        ALARM_RECUR_SPECIAL_NONE,
        ALARM_RECUR_SPECIAL_BIWEEKLY,
        ALARM_RECUR_SPECIAL_MONTHLY,
        ALARM_RECUR_SPECIAL_YEARLY


cdef extern from "dbus/dbus.h":
    ctypedef unsigned int dbus_bool_t
    ctypedef struct DBusMessage

    enum:
        DBUS_TYPE_STRING
        DBUS_TYPE_UINT32
        DBUS_TYPE_INT32
        DBUS_TYPE_BOOLEAN
        DBUS_TYPE_DOUBLE
        DBUS_TYPE_STRING
        DBUS_TYPE_INVALID

    dbus_bool_t dbus_message_append_args(DBusMessage *message,
                                         int first_arg_type, ...)

    # Global functions

    cookie_t alarmd_event_add(alarm_event_t *)
    int alarmd_event_del(cookie_t)
    cookie_t alarmd_event_update(alarm_event_t *)
    alarm_event_t *alarmd_event_get(cookie_t)
    cookie_t *alarmd_event_query(time_t first,
                                      time_t last,
                                      int flag_mask,
                                      int flags,
                                      char *appid)

    # Alarm functions

    alarm_action_t *alarm_action_create()

    char *alarm_action_get_label(alarm_action_t *)
    void alarm_action_set_label(alarm_action_t *, char *label)

    char *alarm_action_get_dbus_interface (alarm_action_t *self)
    void alarm_action_set_dbus_interface (alarm_action_t *self, char* dbus_interface)

    char *alarm_action_get_dbus_service (alarm_action_t *self)
    void alarm_action_set_dbus_service (alarm_action_t *self, char* dbus_service)

    char *alarm_action_get_dbus_path (alarm_action_t *self)
    void alarm_action_set_dbus_path (alarm_action_t *self, char* dbus_path)
    
    char *alarm_action_get_dbus_name (alarm_action_t *self)
    void alarm_action_set_dbus_name (alarm_action_t *self, char* dbus_name)

    int alarm_action_set_dbus_args (alarm_action_t *self, int type, ...)
    void alarm_action_del_dbus_args (alarm_action_t *self)


    char *alarm_action_get_exec_command(alarm_action_t *)
    void alarm_action_set_exec_command(alarm_action_t *, char *value)

    # Recurrence functions
    alarm_recur_t *alarm_recur_create()
    time_t alarm_recur_next(alarm_recur_t *, tm *, char *)
    time_t alarm_recur_align(alarm_recur_t *, tm *, char *)

    # Event functions

    alarm_attr_t *alarm_attr_create(char *name)

    alarm_event_t *alarm_event_create()
    void alarm_event_delete(alarm_event_t *)

    cookie_t alarm_event_get_cookie(alarm_event_t *)
    void alarm_event_set_cookie(alarm_event_t *, cookie_t)

    time_t alarm_event_get_trigger(alarm_event_t *)
    void alarm_event_set_trigger(alarm_event_t *, time_t)

    char* alarm_event_get_title(alarm_event_t *)
    void alarm_event_set_title(alarm_event_t *, char*)

    char* alarm_event_get_message(alarm_event_t *)
    void alarm_event_set_message(alarm_event_t *, char*)

    char* alarm_event_get_sound(alarm_event_t *)
    void alarm_event_set_sound(alarm_event_t *, char*)

    char* alarm_event_get_icon(alarm_event_t *)
    void alarm_event_set_icon(alarm_event_t *, char*)

    char* alarm_event_get_alarm_appid(alarm_event_t *)
    void alarm_event_set_alarm_appid(alarm_event_t *, char*)

    char* alarm_event_get_alarm_tz(alarm_event_t *)
    void alarm_event_set_alarm_tz(alarm_event_t *, char*)

    int alarm_event_is_recurring(alarm_event_t *)

    void alarm_event_get_time(alarm_event_t *, tm *)
    void alarm_event_set_time(alarm_event_t *, tm *)

    int alarm_event_is_sane(alarm_event_t *)

    alarm_action_t *alarm_event_add_actions(alarm_event_t*, int)
    alarm_action_t *alarm_event_get_action(alarm_event_t*, int)
    void alarm_event_del_actions(alarm_event_t*)

    alarm_recur_t *alarm_event_add_recurrences(alarm_event_t*, int)
    alarm_recur_t *alarm_event_get_recurrence(alarm_event_t*, int)
    void alarm_event_del_recurrences(alarm_event_t*)

    int alarm_event_set_action_dbus_args(alarm_event_t *self, int index, int type, ...)
    char *alarm_event_get_action_dbus_args(alarm_event_t *self, int index)
    void alarm_event_del_action_dbus_args(alarm_event_t *self, int index)

