'''Test cases for alarm.Recurrence'''

import unittest
import time
import calendar

import alarm


class TestRecurrenceNext(unittest.TestCase):
    '''Simple tests for alarm.Recurrence.next()'''

    def testSimple(self):
        '''NEXT: Setting the same hour on friday 13th of odd months'''
        rec = alarm.Recurrence()

        h = 12
        m = 56

        rec.mask_min = 1 << m
        rec.mask_hour = 1 << h

        rec.mask_wday |= alarm.RECUR_WDAY_FRI
        rec.mask_mday |= 1 << 13
        rec.mask_mon |= 0x55555555

        trigger = time.localtime()

        for i in range(20):
            next_ocurrence = rec.next(trigger, "BRT")

            self.assertEqual(next_ocurrence.tm_hour, h)
            self.assertEqual(next_ocurrence.tm_min, m)
            self.assertEqual(next_ocurrence.tm_wday, 4)

            trigger = next_ocurrence

    def testMinutes(self):
        '''NEXT: Test a recurrence set to trigger each 13th minute'''

        rec = alarm.Recurrence()

        m = 13

        rec.mask_min = long(1) << m
        rec.mask_hour = alarm.RECUR_HOUR_DONTCARE
        rec.mask_wday |= alarm.RECUR_WDAY_DONTCARE
        rec.mask_mday |= alarm.RECUR_MDAY_DONTCARE
        rec.mask_mon |= alarm.RECUR_MON_DONTCARE

        now = time.localtime()
        tmp = now

        # Override the next trigger on the same hour
        # if minute the test is run is smaller than the target minute
        if now.tm_min < m:
            next_ocurrence = rec.next(tmp, "BRT")
            self.assertEqual(next_ocurrence.tm_min, m)
            self.assertEqual(next_ocurrence.tm_hour, (tmp.tm_hour)%24)

            tmp = next_ocurrence


        for i in range(10):
            next_ocurrence = rec.next(tmp, "BRT")
            self.assertEqual(next_ocurrence.tm_min, m)
            self.assertEqual(next_ocurrence.tm_hour, (tmp.tm_hour+1)%24)

            tmp = next_ocurrence

    def testEndOfMonth(self):
        '''NEXT: Test a recurrence set to the noon of each month's final day'''

        rec = alarm.Recurrence()

        rec.mask_min = long(1) << 00
        rec.mask_hour = 12
        rec.mask_wday = alarm.RECUR_WDAY_DONTCARE
        rec.mask_mday |= alarm.RECUR_MDAY_EOM
        rec.mask_mon = alarm.RECUR_MON_DONTCARE

        tmp = time.localtime()

        for i in range(10):
            next_ocurrence = rec.next(tmp, "BRT")

            # Not sure if we should compare directly to next_ocurrence
            # instead of calculanting the date from tmp
            days = calendar.monthrange(next_ocurrence.tm_year,
                                       next_ocurrence.tm_mon)[1]

            self.assertEqual(days, next_ocurrence.tm_mday)
            self.assertNotEqual(tmp, next_ocurrence)

            tmp = next_ocurrence


class TestRecurrenceAlign(unittest.TestCase):
    '''Simple tests for alarm.Recurrence.align()'''

    def testSimple(self):
        '''ALIGN: Setting the same hour on friday 13th of odd months'''
        rec = alarm.Recurrence()

        h = 12
        m = 56

        rec.mask_min = 1 << m
        rec.mask_hour = 1 << h

        rec.mask_wday |= alarm.RECUR_WDAY_FRI
        rec.mask_mday |= 1 << 13
        rec.mask_mon |= 0x55555555

        trigger = time.localtime()

        trigger = rec.align(trigger, "BRT")

        for i in range(20):
            next_ocurrence = rec.align(trigger, "BRT")

            self.assertEqual(next_ocurrence.tm_hour, h)
            self.assertEqual(next_ocurrence.tm_min, m)
            self.assertEqual(next_ocurrence.tm_wday, 4)

            self.assertEqual(next_ocurrence, trigger)

            trigger = next_ocurrence

    def testMinutes(self):
        '''ALIGN: Test a recurrence set to trigger each 13th minute'''

        rec = alarm.Recurrence()

        m = 13

        rec.mask_min = long(1) << m
        rec.mask_hour = alarm.RECUR_HOUR_DONTCARE
        rec.mask_wday |= alarm.RECUR_WDAY_DONTCARE
        rec.mask_mday |= alarm.RECUR_MDAY_DONTCARE
        rec.mask_mon |= alarm.RECUR_MON_DONTCARE

        now = time.localtime()
        tmp = now

        first_ocurrence = rec.align(tmp, "BRT")

        self.assertEqual(first_ocurrence.tm_min, m)

        for i in range(10):
            # Once the time is aligned, align() shouldn't change the time
            next_ocurrence = rec.align(first_ocurrence, "BRT")
            self.assertEqual(next_ocurrence, first_ocurrence)
            first_ocurrence = next_ocurrence

    def testEndOfMonth(self):
        '''ALIGN: Test a recurrence set to the noon of each month's final day'''

        rec = alarm.Recurrence()

        rec.mask_min = long(1) << 00
        rec.mask_hour = 12
        rec.mask_wday = alarm.RECUR_WDAY_DONTCARE
        rec.mask_mday |= alarm.RECUR_MDAY_EOM
        rec.mask_mon = alarm.RECUR_MON_DONTCARE

        tmp = time.localtime()

        tmp = rec.align(tmp, "BRT")

        for i in range(10):
            next_ocurrence = rec.align(tmp, "BRT")

            # Not sure if we should compare directly to next_ocurrence
            # instead of calculanting the date from tmp
            days = calendar.monthrange(next_ocurrence.tm_year,
                                       next_ocurrence.tm_mon)[1]

            self.assertEqual(tmp, next_ocurrence)

            tmp = next_ocurrence


if __name__ == '__main__':
    unittest.main()
