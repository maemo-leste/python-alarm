#!/usr/bin/env python

import alarm
import sys
import time

def show_alarm_details(cookie):
    event = alarm.get_event(cookie)
    tmo = time.time()

    print "Cookie: %d" % cookie
    print "AppID: %s" % event.appid
    print "Trigger: T%+ld, %s" % (tmo, time.ctime(event.trigger))
    print "Message: %s" % event.message

    for i in range(event.action_count):
        print "Action %d: label= %s" % (i, event.get_action(i).label)

def main():
    show_alarm_details(int(sys.argv[1]))

if __name__ == '__main__':
    main()
