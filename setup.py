
from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

setup(
    cmdclass = {'build_ext':build_ext},
    ext_modules = [Extension('alarm',
                            ['alarm.pyx'],
                            include_dirs=['/usr/include/alarmd',
                                        '/usr/include/dbus-1.0',
                                        '/usr/lib/dbus-1.0/include'],
                            libraries=['alarm', 'dbus-1', 'pthread'],
                            extra_compile_args=["-Werror"]),]
)
