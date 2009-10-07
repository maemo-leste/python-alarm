
import alarm
from time import time


def add_two_button_alarm():
    event = alarm.Event()
    event.appid = 'myappid'
    event.message = 'Example Message'

    event.alarm_time = time() + 10

    action_stop, action_snooze = event.add_actions(2)
    action_stop.label = 'Stop'
    action_stop.flags |= alarm.ACTION_WHEN_RESPONDED | alarm.ACTION_TYPE_NOP

    action_snooze.label = 'Snooze'
    action_snooze.flags |= alarm.ACTION_WHEN_RESPONDED | alarm.ACTION_TYPE_SNOOZE

    print event.is_sane()

    cookie = alarm.add_event(event)

    return cookie

def main():
    cookie = add_two_button_alarm()
    print cookie

if __name__ == '__main__':
    main()
