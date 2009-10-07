#!/usr/bin/env python

import sys
from time import time, localtime

import alarm


def main():
    event = alarm.Event()
    event.appid = 'simple_recurrence'
    event.message = 'Example Recurring Message'

    event.alarm_time = time() + 5

    action = event.add_actions(1)[0]

    action.flags |= alarm.ACTION_WHEN_RESPONDED | alarm.ACTION_TYPE_NOP
    action.label = 'Stop'

    recurrence = event.add_recurrences(1)[0]

    recurrence.mask_min |= alarm.RECUR_MIN_ALL
    recurrence.mask_hour |= alarm.RECUR_HOUR_DONTCARE
    recurrence.mask_mday |= alarm.RECUR_MDAY_DONTCARE
    recurrence.mask_wday |= alarm.RECUR_WDAY_DONTCARE
    recurrence.mask_mon |= alarm.RECUR_MON_DONTCARE
    recurrence.special |= alarm.RECUR_SPECIAL_NONE

    event.recurrences_left = 5

    print alarm.add_event(event)

if __name__ == '__main__':
    main()
