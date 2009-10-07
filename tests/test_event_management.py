
import unittest

import alarm

class TestPointerManagement(unittest.TestCase):
    def testCreateDelete(self):
        '''Create an Event and immediately delete it'''
        evt = alarm.Event()
        del evt

if __name__ == '__main__':
    unittest.main()
