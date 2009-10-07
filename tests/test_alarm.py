
import unittest

import alarm
import os
from time import struct_time, localtime, time, mktime, sleep

class AlarmCookie(unittest.TestCase):
    def testCookie(self):
        obj = alarm.Event()
        self.assert_(isinstance(obj.cookie, int))

class AlarmTime(unittest.TestCase):
    def testSetTimeStruct(self):
        obj = alarm.Event()
        now = localtime()
        obj.time = now
        self.assertEqual(obj.time, mktime(now))

    def testSetTimeSeconds(self):
        obj = alarm.Event()
        now = time()
        obj.time = now
        self.assertEqual(obj.time, int(now)) # C's time_t is an int

class ActionProperties(unittest.TestCase):

    def setUp(self):
        # FIXME Currently we can't create actions directly
        self.event = alarm.Event()
        self.action = self.event.add_actions(1)[0]

    def testLabel(self):
        self.assertEqual(self.action.label, '')
        self.action.label = 'Foobar'
        self.assertEqual(self.action.label, 'Foobar')

    def testFlags(self):
        self.assertEqual(self.action.flags, alarm.ACTION_TYPE_NOP)

        self.action.flags |= alarm.ACTION_WHEN_TRIGGERED | alarm.ACTION_TYPE_NOP

        self.assert_(self.action.flags | alarm.ACTION_WHEN_TRIGGERED)

class AddActions(unittest.TestCase):

    def testCreatedActions(self):
        event = alarm.Event()
        actions = event.add_actions(3)

        self.assertEqual(len(actions), 3)
        for action in actions:
            self.assert_(isinstance(action, alarm.Action))
            self.assert_(action.valid)

    def testCreateInSequence(self):
        event = alarm.Event()
        actions_first = event.add_actions(3)
        actions_second = event.add_actions(3) # invalidates actions_first

        self.assertEqual(len(actions_first), 3)
        for action in actions_first:
            self.assert_(isinstance(action, alarm.Action))
            self.assert_(not action.valid)


        self.assertEqual(len(actions_second), 3)
        for action in actions_second:
            self.assert_(isinstance(action, alarm.Action))
            self.assert_(action.valid)

        # Original actions were moved
        for i in range(3):
            action = event.get_action(i)
            self.assert_(isinstance(action, alarm.Action))
            self.assert_(action.valid)

        # Get actions also retrieve the new ones
        for i in range(3, 6):
            action = event.get_action(i)
            self.assert_(isinstance(action, alarm.Action))
            self.assert_(action.valid)
            self.assert_(action is actions_second[i-3])


class GetActions(unittest.TestCase):
    def testIdentity(self):
        obj = alarm.Event()
        obj.add_actions(2)

        action1 = obj.get_action(0)
        action2 = obj.get_action(0)
        action_other = obj.get_action(1)

        self.assert_(isinstance(action1, alarm.Action))
        self.assert_(action1 is action2)
        self.assert_(not(action1 is action_other))

    def testInvalidate(self):
        obj = alarm.Event()
        obj.add_actions(3)
        action1 = obj.get_action(0)

        self.assert_(action1.valid)

        obj.add_actions(3)

        self.assert_(not action1.valid)

    def testOutOfRange(self):
        obj = alarm.Event()
        self.assertRaises(IndexError, obj.get_action, 0)

class DeleteActions(unittest.TestCase):
    def testDelete(self):
        obj = alarm.Event()
        obj.add_actions(1)
        action1 = obj.get_action(0)
        self.assert_(action1.valid)

        obj.delete_actions()

        self.assert_(not action1.valid)

class AddRecurrence(unittest.TestCase):
    def testCreatedRecurrences(self):
        event = alarm.Event()
        recurrences = event.add_recurrences(3)

        self.assertEqual(len(recurrences), 3)
        for recurrence in recurrences:
            self.assert_(isinstance(recurrence, alarm.Recurrence))
            self.assert_(recurrence.valid)

    def testCreateInSequence(self):
        event = alarm.Event()
        recurrences_first = event.add_recurrences(3)
        recurrences_second = event.add_recurrences(3)

        self.assertEqual(len(recurrences_first), 3)
        for recurrence in recurrences_first:
            self.assert_(isinstance(recurrence, alarm.Recurrence))
            self.assert_(not recurrence.valid)


        self.assertEqual(len(recurrences_second), 3)
        for recurrence in recurrences_second:
            self.assert_(isinstance(recurrence, alarm.Recurrence))
            self.assert_(recurrence.valid)

        # Original recurrences were moved
        for i in range(3):
            recurrence = event.get_recurrence(i)
            self.assert_(isinstance(recurrence, alarm.Recurrence))
            self.assert_(recurrence.valid)

        # Get recurrences also retrieve the new ones
        for i in range(3, 6):
            recurrence = event.get_recurrence(i)
            self.assert_(isinstance(recurrence, alarm.Recurrence))
            self.assert_(recurrence.valid)
            self.assert_(recurrence is recurrences_second[i-3])



class GetRecurrence(unittest.TestCase):
    def testIdentity(self):
        obj = alarm.Event()
        obj.add_recurrences(2)

        recurrence1 = obj.get_recurrence(0)
        recurrence2 = obj.get_recurrence(0)
        recurrence_other = obj.get_recurrence(1)

        self.assert_(isinstance(recurrence1, alarm.Recurrence))
        self.assert_(recurrence1 is recurrence2)
        self.assert_(not(recurrence1 is recurrence_other))

    def testInvalidate(self):
        obj = alarm.Event()
        obj.add_recurrences(3)
        recurrence1 = obj.get_recurrence(0)

        self.assert_(recurrence1.valid)

        obj.add_recurrences(3)

        self.assert_(not recurrence1.valid)

    def testOutOfRance(self):
        obj = alarm.Event()
        self.assertRaises(IndexError, obj.get_recurrence, 0)

class DeleteRecurrence(unittest.TestCase):
    def testDelete(self):
        obj = alarm.Event()
        obj.add_recurrences(1)
        recurrence1 = obj.get_recurrence(0)
        self.assert_(recurrence1.valid)

        obj.delete_recurrences()

        self.assert_(not recurrence1.valid)

class EventManagement(unittest.TestCase):

    def testAddInvalidEvent(self):
        '''Add an invalid (insane) event should rise an exception'''
        event = alarm.Event()
        self.assertRaises(alarm.InvalidEventException, alarm.add_event, event)

    def testCreateDelete(self):
        '''General lifecycle of an Event: Add, Retrieve, Update, Delete'''
        event = alarm.Event()
        appid = 'aaaa'
        event.appid = appid
        action = event.add_actions(1)[0]
        action.flags |= alarm.ACTION_WHEN_TRIGGERED | alarm.ACTION_TYPE_SNOOZE

        cookie = alarm.add_event(event)

        # Compare with 'cookie', as event.cookie is still 0 after adding
        event2 = alarm.get_event(cookie)
        self.assertEqual(cookie, event2.cookie)
        self.assertEqual(appid, event2.appid)

        event2.alarm_time = time() + 3
        alarm.update_event(event2)

        alarm.delete_event(cookie)
        self.assertRaises(IndexError, alarm.get_event, cookie)

class ActionCommand(unittest.TestCase):
    '''Test case for triggering an action that will execute a command'''

    def setUp(self):
        self.event = alarm.Event()
        self.event.appid = 'Foobar'
        self.event.alarm_time = time() + 1

    def tearDown(self):
        try:
            alarm.delete_event(self.cookie)
            del self.cookie
        except:
            pass

    def testExecuteCommand(self):
        '''Execute a command through alarm activation'''


        action = self.event.add_actions(1)[0]
        action.flags |= alarm.ACTION_WHEN_TRIGGERED | alarm.ACTION_TYPE_EXEC
        action.command = 'touch /tmp/alarm.txt'

        self.cookie = alarm.add_event(self.event)

        sleep(2)

        self.assert_(os.path.isfile('/tmp/alarm.txt'))


if __name__ == '__main__':
    unittest.main()
