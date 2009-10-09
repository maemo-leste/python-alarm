
'''Test cases for making dbus calls through alarm events'''

from __future__ import with_statement

import unittest
import os
import time
import alarm

confirmation_file = '/tmp/dbus_alarm_called.txt'

receiver_source = '''#!/usr/bin/python2.5

import gobject
import dbus
import dbus.service
import dbus.mainloop.glib

class Example(dbus.service.Object):
    @dbus.service.method('org.foobar.Dummy',
                        in_signature='', out_signature='')
    def CallMe(self):
        open('%s', 'w').close()
        mainloop.quit()

    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)

if __name__ == '__main__':
    session_bus = dbus.SessionBus()
    name = dbus.service.BusName('org.foobar.Dummy', session_bus)
    object = Example(session_bus, '/SomeObject')
    mainloop = gobject.MainLoop()
    mainloop.run()

''' % (confirmation_file)


class DBusAlarm(unittest.TestCase):

    def setUp(self):
        self.name = 'org.foobar.Dummy'
        self.service = '/usr/share/dbus-1/services/%s.service''' % self.name
        self.receiver = '/tmp/fake_dbus_alarm.py'

        self.object_path = ''
        self.interface = ''
        self.method = ''

        # Prepare DBus files
        f = open(self.service, 'w')
        f.write('[D-BUS Service]\n' +
                'Name=org.foobar.Dummy\n' +
                'Exec=' + self.receiver + '\n')
        f.close()

        f = open(self.receiver, 'w')
        f.write(receiver_source)
        f.close()

        os.chmod(self.receiver, 0755)


    def tearDown(self):
        os.remove(self.service)
        os.remove(self.receiver)
        try:
            os.remove(confirmation_file)
        except:
            pass

    def testSimple(self):
        '''Simple DBus call through alarm'''

        event = alarm.Event()
        event.appid = 'dbus-alarm-test'
        event.alarm_time = time.time() + 2

        action = event.add_actions(1)[0]
        action.flags |= alarm.ACTION_WHEN_TRIGGERED | alarm.ACTION_TYPE_DBUS

        action.dbus_service = 'org.foobar.Dummy'
        action.dbus_path = '/SomeObject'
        action.dbus_interface = 'org.foobar.Dummy'
        action.dbus_name = 'CallMe'

        self.cookie = alarm.add_event(event)

        time.sleep(3)

        self.assert_(os.path.isfile(confirmation_file))

if __name__ == '__main__':
    unittest.main()
