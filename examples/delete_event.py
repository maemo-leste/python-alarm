#!/usr/bin/env python

import alarm
import sys


def main():
    alarm.delete_event(int(sys.argv[1]))

    print "Deleted event %s" % sys.argv[1]

if __name__ == '__main__':
    main()
