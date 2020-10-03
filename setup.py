from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext


import subprocess
def pkgconfig(package, kw):
    flag_map = {'-I': 'include_dirs', '-L': 'library_dirs', '-l': 'libraries'}
    output = subprocess.check_output(
        ['pkg-config', '--cflags', '--libs', package])
    for token in output.strip().split():
        kw.setdefault(flag_map.get(token[:2]), []).append(token[2:])
    return kw


extension_kwargs = {}

extension_kwargs = pkgconfig('alarm', extension_kwargs)
extension_kwargs.update(pkgconfig('dbus-1', extension_kwargs))
extension_kwargs['libraries'] += ['pthread']
extension_kwargs['extra_compile_args'] = ['-Werror']

setup(
    cmdclass = {'build_ext':build_ext},
    ext_modules = [Extension('alarm',
                            ['alarm.pyx'],
                            **extension_kwargs)]
)
