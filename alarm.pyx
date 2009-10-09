import time
from libalarm cimport *


# Enums

ACTION_TYPE_NOP = ALARM_ACTION_TYPE_NOP
ACTION_TYPE_SNOOZE = ALARM_ACTION_TYPE_SNOOZE
ACTION_TYPE_DBUS = ALARM_ACTION_TYPE_DBUS
ACTION_TYPE_EXEC = ALARM_ACTION_TYPE_EXEC
ACTION_TYPE_DISABLE = ALARM_ACTION_TYPE_DISABLE
ACTION_WHEN_QUEUED = ALARM_ACTION_WHEN_QUEUED
ACTION_WHEN_DELAYED = ALARM_ACTION_WHEN_DELAYED
ACTION_WHEN_TRIGGERED = ALARM_ACTION_WHEN_TRIGGERED
ACTION_WHEN_DISABLED = ALARM_ACTION_WHEN_DISABLED
ACTION_WHEN_RESPONDED = ALARM_ACTION_WHEN_RESPONDED
ACTION_WHEN_DELETED = ALARM_ACTION_WHEN_DELETED
ACTION_DBUS_USE_ACTIVATION = ALARM_ACTION_DBUS_USE_ACTIVATION
ACTION_DBUS_USE_SYSTEMBUS = ALARM_ACTION_DBUS_USE_SYSTEMBUS
ACTION_DBUS_ADD_COOKIE = ALARM_ACTION_DBUS_ADD_COOKIE
ACTION_EXEC_ADD_COOKIE = ALARM_ACTION_EXEC_ADD_COOKIE
ACTION_TYPE_MASK = ALARM_ACTION_TYPE_MASK
ACTION_WHEN_MASK = ALARM_ACTION_WHEN_MASK

# Recurrence flags

RECUR_MIN_DONTCARE = ALARM_RECUR_MIN_DONTCARE
RECUR_MIN_ALL = PyLong_FromLongLong(ALARM_RECUR_MIN_ALL)
RECUR_HOUR_DONTCARE = ALARM_RECUR_HOUR_DONTCARE
RECUR_HOUR_ALL = ALARM_RECUR_HOUR_ALL

RECUR_MDAY_DONTCARE = ALARM_RECUR_MDAY_DONTCARE
RECUR_MDAY_ALL = ALARM_RECUR_MDAY_ALL
RECUR_MDAY_EOM = ALARM_RECUR_MDAY_EOM

RECUR_WDAY_DONTCARE = ALARM_RECUR_WDAY_DONTCARE
RECUR_WDAY_ALL = ALARM_RECUR_WDAY_ALL
RECUR_WDAY_SUN = ALARM_RECUR_WDAY_SUN
RECUR_WDAY_MON = ALARM_RECUR_WDAY_MON
RECUR_WDAY_TUE = ALARM_RECUR_WDAY_TUE

RECUR_WDAY_WED = ALARM_RECUR_WDAY_WED
RECUR_WDAY_THU = ALARM_RECUR_WDAY_THU
RECUR_WDAY_FRI = ALARM_RECUR_WDAY_FRI
RECUR_WDAY_SAT = ALARM_RECUR_WDAY_SAT
RECUR_WDAY_MONFRI = ALARM_RECUR_WDAY_MONFRI
RECUR_WDAY_SATSUN = ALARM_RECUR_WDAY_SATSUN

RECUR_MON_DONTCARE = ALARM_RECUR_MON_DONTCARE
RECUR_MON_ALL = ALARM_RECUR_MON_ALL
RECUR_MON_JAN = ALARM_RECUR_MON_JAN
RECUR_MON_FEB = ALARM_RECUR_MON_FEB
RECUR_MON_MAR = ALARM_RECUR_MON_MAR
RECUR_MON_APR = ALARM_RECUR_MON_APR
RECUR_MON_MAY = ALARM_RECUR_MON_MAY
RECUR_MON_JUN = ALARM_RECUR_MON_JUN
RECUR_MON_JUL = ALARM_RECUR_MON_JUL
RECUR_MON_AUG = ALARM_RECUR_MON_AUG
RECUR_MON_SEP = ALARM_RECUR_MON_SEP
RECUR_MON_OCT = ALARM_RECUR_MON_OCT
RECUR_MON_NOW = ALARM_RECUR_MON_NOW
RECUR_MON_DEC = ALARM_RECUR_MON_DEC

RECUR_SPECIAL_NONE = ALARM_RECUR_SPECIAL_NONE
RECUR_SPECIAL_BIWEEKLY = ALARM_RECUR_SPECIAL_BIWEEKLY
RECUR_SPECIAL_MONTHLY = ALARM_RECUR_SPECIAL_MONTHLY
RECUR_SPECIAL_YEARLY = ALARM_RECUR_SPECIAL_YEARLY



cdef class Wrapper:
    cdef void *obj
    cdef public bint valid

    def __init__(self):
        self.obj = NULL
        self.valid = False

    cdef _set_underlying_pointer(self, void *obj):
        self.obj = obj
        self.valid = True

    def _raise_if_invalid(self):
        if not self.valid:
            raise InvalidObjectException()

cdef class WrapperManager:
    cdef dict instances
    cdef type klass

    def __init__(self, klass):
        self.instances = {}
        self.klass = klass

    cdef register_instance(self, void *c_pointer):
        '''Registers a new Action instance, associating it to the
        alarm_action_t pointer'''

        cdef Wrapper wrapper

        key = PyInt_FromLong(<long>c_pointer)

        if key in self.instances:
            wrapper = self.instances[key]
        else:
            wrapper = self.klass()
            wrapper._set_underlying_pointer(c_pointer)
            self.instances[key] = wrapper

        return wrapper

    def reset(self):
        for value in self.instances.values():
            value.valid = False

        self.instances = {}

cdef class Action(Wrapper):
    '''Represents event actions'''

    cdef inline alarm_action_t *_obj(self) except NULL:
        self._raise_if_invalid()

        return <alarm_action_t *>self.obj

    property label:
        '''Name of the button'''
        def __get__(self):
            return alarm_action_get_label(self._obj())
        def __set__(self, char* value):
            alarm_action_set_label(self._obj(), value)

    property flags:
        '''Flags for the action behavior

        The following bits define when action is to be taken:

        - alarm.ACTION_WHEN_QUEUED
        - alarm.ACTION_WHEN_DELAYED
        - alarm.ACTION_WHEN_TRIGGERED
        - alarm.ACTION_WHEN_DISABLED
        - alarm.ACTION_WHEN_RESPONDED
        - alarm.ACTION_WHEN_DELETED

        Normally, RESPONDED is used for dialog buttons and TRIGGERED for
        non-interactive alarms. The other options can be used for debugging
        or tracing alarm state changes.

        The action to be done is defined in the TYPE bits:

        - alarm.ACTION_TYPE_NOP - No operation
        - alarm.ACTION_TYPE_SNOOZE - Snooze, using the custom snooze time
        - alarm.ACTION_TYPE_DBUS - Make a dbus method call/emit a signal
        - alarm.ACTION_TYPE_EXEC - Execute a command
        '''
        def __get__(self):
            return self._obj().flags
        def __set__(self, alarmactionflags value):
            self._obj().flags = value

    property dbus_interface:
        def __get__(self):
            return alarm_action_get_dbus_interface(self._obj())
        def __set__(self, char* value):
            alarm_action_set_dbus_interface(self._obj(), value)

    property dbus_service:
        def __get__(self):
            return alarm_action_get_dbus_service(self._obj())
        def __set__(self, char* value):
            alarm_action_set_dbus_service(self._obj(), value)

    property dbus_path:
        def __get__(self):
            return alarm_action_get_dbus_path(self._obj())
        def __set__(self, char* value):
            alarm_action_set_dbus_path(self._obj(), value)

    property dbus_name:
        def __get__(self):
            return alarm_action_get_dbus_name(self._obj())
        def __set__(self, char* value):
            alarm_action_set_dbus_name(self._obj(), value)

    def set_dbus_args(self, dbus_args=tuple()):
        cdef int arg_type
        cdef value arg_value

        if not isinstance(dbus_args, tuple):
            raise TypeError, "DBUS arguments must be in a tuple."
        for py_arg in tuple:
            #detect argument type
            if isinstance(py_arg, str):
                arg_type = DBUS_TYPE_STRING
                arg_value.s = py_arg
            elif isinstance(py_arg, bool):
                arg_type = DBUS_TYPE_BOOLEAN
                arg_value.b = py_arg
            elif isinstance(py_arg, int):
                if py_arg < 0:
                    arg_type = DBUS_TYPE_INT32
                    arg_value.i = py_arg
                else:
                    arg_type = DBUS_TYPE_UINT32
                    arg_value.u = py_arg
            elif isinstance(py_arg, float):
                arg_type = DBUS_TYPE_DOUBLE
                arg_value.d = py_arg
            else:
                arg_type = DBUS_TYPE_INVALID
                arg_value.i = 0
            
            #finally, let's call the function
            alarm_action_set_dbus_args(<alarm_action_t *>self.obj, arg_type, &arg_value, DBUS_TYPE_INVALID)

    def del_dbus_args(self):
        alarm_action_del_dbus_args(<alarm_action_t *>self.obj)

    property command:
        '''Command to be executed by this action'''
        def __get__(self):
            return alarm_action_get_exec_command(self._obj())
        def __set__(self, char *value):
            alarm_action_set_exec_command(self._obj(), value)



cdef class Recurrence(Wrapper):
    '''Recurrence rules representation

    Recurrence rules are defined by masks in this class' fields. Each field
    has a number of flags for predefined values, like months and weekdays.
    Alternatively, the values can be set manually in the bits.

    For example, to set the recurrence to trigger on the 22nd hour, use:

    rec_obj.mask_hour |= 1 << 22
    '''

    def __init__(self, create_instance=True):
        Wrapper.__init__(self)
        cdef alarm_recur_t *recur

        if create_instance:
            recur = alarm_recur_create()
            self._set_underlying_pointer(recur)

    cdef inline alarm_recur_t *_obj(self) except NULL:
        '''Helper method to avoid writing casts everywhere'''
        self._raise_if_invalid()
        return <alarm_recur_t *>self.obj

    property mask_min:
        def __get__(self):
            return self._obj().mask_min
        def __set__(self, long long value):
            # Use long long instead of flag type as we need a
            # Python long
            self._obj().mask_min = value

    property mask_hour:
        def __get__(self):
            return self._obj().mask_hour
        def __set__(self, alarmrecurflags value):
            self._obj().mask_hour = value

    property mask_mday:
        def __get__(self):
            return self._obj().mask_mday
        def __set__(self, alarmrecurflags value):
            self._obj().mask_mday = value

    property mask_wday:
        def __get__(self):
            return self._obj().mask_wday
        def __set__(self, alarmrecurflags value):
            self._obj().mask_wday = value

    property mask_mon:
        def __get__(self):
            return self._obj().mask_mon
        def __set__(self, alarmrecurflags value):
            self._obj().mask_mon = value

    property special:
        def __get__(self):
            return self._obj().special
        def __set__(self, alarmrecurflags value):
            self._obj().special = value



    def next(self, trigger, char *timezone):
        '''Aligns broken down time to recurrence rules, always advancing time.

        Arguments:

        trigger - time.struct with base time for calculation
        timezone - timezone to use for evaluation

        Returns a new struct_time aligned to the recurrence rules, always
        advancing the time.

        Note: The C version returns a time_t value and modifies the trigger
        inplace.
        '''

        cdef time_t secs = time.mktime(trigger)
        cdef tm *t = localtime(&secs)
        cdef time_t secs_next

        secs_next = alarm_recur_next(self._obj(), t, timezone)

        secs = mktime(t)
        return time.localtime(secs)

    def align(self, trigger, char *timezone):
        '''Aligns broken down time to recurrence rules, trying to not advance
        time.

        Arguments:

        trigger - time.struct with base time for calculation
        timezone - timezone to use for evaluation

        Returns a new struct_time aligned to the recurrence rules.

        Note: The C version returns a time_t value and modifies the trigger
        inplace.
        '''

        cdef time_t secs = time.mktime(trigger)
        cdef tm *t = localtime(&secs)
        cdef time_t secs_next

        secs_next = alarm_recur_align(self._obj(), t, timezone)

        secs = mktime(t)
        return time.localtime(secs)


#TODO Shouldn't Event be a subclass of Wrapper?
cdef class Event:
    '''Alarm Events.

    Events are the main class in the alarm subsystem. The the activation
    time the subsystem will check the actions for the triggered event and
    execute them, updating the trigger following the recursion rules.'''

    cdef alarm_event_t *obj
    cdef WrapperManager action_manager
    cdef WrapperManager recurrence_manager
    cdef bint valid

    def __init__(self, create_instance=True):
        if create_instance:
            self.obj = alarm_event_create()
            self.valid = True
        else:
            self.obj = NULL
            self.valid = False

        self.action_manager = WrapperManager(Action)
        self.recurrence_manager = WrapperManager(Recurrence)

    def __del__(self):
        if self.valid:
            alarm_event_delete(self.obj)

    def __richcmp__(Event self, Event other, function):
        if function == 2:
            return self._obj() == other.obj
        elif function == 3:
            return self._obj() != other.obj
        else:
            return False

    def _invalidate(self):
        alarm_event_delete(self._obj())
        self.valid = False

    cdef alarm_event_t *_obj(self) except NULL:
        self._raise_if_invalid()
        return self.obj

    def _raise_if_invalid(self):
        if not self.valid:
            raise InvalidObjectException()

    cdef _set_underlying_pointer(Event self, alarm_event_t *instance):
        self.obj = instance
        self.valid = True

    property cookie:
        def __get__(self):
            return alarm_event_get_cookie(self._obj())
        def __set__(self, cookie_t value):
            alarm_event_set_cookie(self._obj(), value)

    property trigger:
        def __get__(self):
            return alarm_event_get_trigger(self._obj())
        def __set__(self, time_t value):
            alarm_event_set_trigger(self._obj(), value)

    property title:
        def __get__(self):
            return alarm_event_get_title(self._obj())
        def __set__(self, char* value):
            alarm_event_set_title(self._obj(), value)

    property message:
        def __get__(self):
            return alarm_event_get_message(self._obj())
        def __set__(self, char* value):
            alarm_event_set_message(self._obj(), value)

    property sound:
        def __get__(self):
            return alarm_event_get_sound(self._obj())
        def __set__(self, char* value):
            alarm_event_set_sound(self._obj(), value)

    property icon:
        def __get__(self):
            return alarm_event_get_icon(self._obj())
        def __set__(self, char* value):
            alarm_event_set_icon(self._obj(), value)

    property appid:
        def __get__(self):
            return alarm_event_get_alarm_appid(self._obj())
        def __set__(self, char* value):
            alarm_event_set_alarm_appid(self._obj(), value)

    property timezone:
        def __get__(self):
            return alarm_event_get_alarm_tz(self._obj())
        def __set__(self, char* value):
            alarm_event_set_alarm_tz(self._obj(), value)

    property action_count:
        def __get__(self):
            return self._obj().action_cnt

    property recurrences_left:
        '''The number of remaining ocurrences for this event'''
        def __get__(self):
            return self._obj().recur_count
        def __set__(self, int value):
            self._obj().recur_count = value

    property recurrences_count:
        '''The number of recurrence rules'''
        def __get__(self):
            return self._obj().recurrence_cnt

    def is_recurring(self):
        '''Returns True if this event is recurring.'''
        if alarm_event_is_recurring(self._obj()):
            return True
        else:
            return False

    def is_sane(self):
        '''Returns True if no major errors are found'''
        if alarm_event_is_sane(self._obj()) == 1:
            return True
        else:
            return False

    property time:
        '''Time of activation for this alarm event.

        When setting it, the value can be a float with seconds since
        Epoch or a time.struct_time instance.

        Returns the time in seconds since Epoch'''
        def __get__(self):
            cdef tm t
            alarm_event_get_time(self._obj(), &t)

            #Convert to a python value through time_t
            t2 = mktime(&t)
            return t2

        def __set__(self, value):
            cdef tm *t
            cdef time_t secs

            if isinstance(value, float):
                secs = value
                t = localtime(&secs)
            elif isinstance(value, time.struct_time):
                secs = time.mktime(value)
                t = localtime(&secs)
            else:
                raise TypeError("Must be a number or time.struct")

            alarm_event_set_time(self._obj(), t)

    property alarm_time:
        '''Trigger this alarm event.'''
        def __get__(self):
            return self._obj().alarm_time

        def __set__(self, long value):
            self._obj().alarm_time = value

    def set_action_dbus_args(self, index, dbus_args=tuple()):
        cdef int arg_type
        cdef value arg_value

        if not isinstance(dbus_args, tuple):
            raise TypeError, "DBUS arguments must be in a tuple."
        for py_arg in tuple:
            #detect argument type
            if isinstance(py_arg, str):
                arg_type = DBUS_TYPE_STRING
                arg_value.s = py_arg
            elif isinstance(py_arg, bool):
                arg_type = DBUS_TYPE_BOOLEAN
                arg_value.b = py_arg
            elif isinstance(py_arg, int):
                if py_arg < 0:
                    arg_type = DBUS_TYPE_INT32
                    arg_value.i = py_arg
                else:
                    arg_type = DBUS_TYPE_UINT32
                    arg_value.u = py_arg
            elif isinstance(py_arg, float):
                arg_type = DBUS_TYPE_DOUBLE
                arg_value.d = py_arg
            else:
                arg_type = DBUS_TYPE_INVALID
                arg_value.i = 0
            
            #finally, let's call the function
            alarm_event_set_action_dbus_args(<alarm_event_t *>self.obj, index, arg_type, &arg_value, DBUS_TYPE_INVALID)

    def get_action_dbus_args(self, index):
        return alarm_event_get_action_dbus_args(<alarm_event_t *>self.obj, index)
    
    def del_action_dbus_args(self, index):
        alarm_event_del_action_dbus_args(<alarm_event_t *>self.obj, index)
    
    # The ugly part of adding actions, attributes, etc

    def add_actions(self, number):
        '''Adds and initializes a number of actions to this event.

        Adds a number of actions to this event. Previously added actions will
        be invalidated.

        Returns: List of newly created events'''

        cdef alarm_action_t *c_actions
        actions = []

        self.action_manager.reset()
        c_actions = alarm_event_add_actions(self._obj(), int(number))

        for i in range(number):
            actions.append(self.action_manager.register_instance(&c_actions[i]))

        return actions

    def get_action(self, index):
        cdef alarm_action_t *c_action

        c_action = alarm_event_get_action(self._obj(), index)
        if c_action != NULL:
            action = self.action_manager.register_instance(c_action)
        else:
            raise IndexError()
        return action

    def delete_actions(self):
        alarm_event_del_actions(self._obj())
        self.action_manager.reset()

    def add_recurrences(self, number):
        '''Adds and initializes a number of recurrences to this event.

        Adds a number of recurrences to this event. Previously added recurrences will
        be invalidated.

        Returns: List of newly created events'''

        cdef alarm_recur_t *c_recurrences
        recurrences = []

        self.recurrence_manager.reset()
        c_recurrences = alarm_event_add_recurrences(self._obj(), int(number))

        for i in range(number):
            recurrences.append(self.recurrence_manager.register_instance(&c_recurrences[i]))

        return recurrences

    def get_recurrence(self, index):
        cdef alarm_recur_t *c_recurrence

        c_recurrence = alarm_event_get_recurrence(self._obj(), index)

        if c_recurrence != NULL:
            recurrence = self.recurrence_manager.register_instance(c_recurrence)
        else:
            raise IndexError()
        return recurrence

    def delete_recurrences(self):
        alarm_event_del_recurrences(self._obj())
        self.recurrence_manager.reset()


# Global Functions

class InvalidEventException(Exception):
    pass

class InvalidObjectException(Exception):
    pass

def add_event(Event event):
    '''Adds an event to the alarm queue'''
    cookie = alarmd_event_add(event.obj)
    if cookie == 0:
        raise InvalidEventException()

    event._invalidate()

    return cookie

def delete_event(cookie_t cookie):
    '''Deletes event from the alarm queue'''
    return alarmd_event_del(cookie)

def get_event(cookie_t cookie):
    '''Fetches event details'''
    cdef alarm_event_t *c_event
    cdef Event event

    c_event = alarmd_event_get(cookie)

    if c_event == NULL:
        raise IndexError()

    event = Event(create_instance=False)
    event._set_underlying_pointer(c_event)
    return event

def update_event(Event event):
    '''Updates an event already in the alarm queue.
    
    Works like deleting this event and adding it again.'''
    return alarmd_event_update(event.obj)

def query_event(time_t first, time_t last,
                int flag_mask, int flags,
                char *appid):
    '''Returns cookies for events occurring between the times
    first and last, filtered by flags and appid'''
    cdef cookie_t *c_cookies, *t
    cookies = []

    c_cookies = alarmd_event_query(first, last, flag_mask,
                                flags, appid)
    i = 0
    while (c_cookies[i]) != 0:
        cookies.append(c_cookies[i])
        i += 1
    return cookies
