import fnmatch
import os

matches = []
for root, dirnames, filenames in os.walk('src'):
  for filename in fnmatch.filter(filenames, '*.cpp'):
    matches.append(os.path.join(root, filename))

VariantDir('build', 'src')
src = [match.replace('src', 'build', 1) for match in matches]

env = Environment()
env["ENV"]["PKG_CONFIG_PATH"] = os.environ.get("PKG_CONFIG_PATH")
env.ParseConfig('pkg-config --cflags --libs opencv')
env['LIBS'].remove('ippicv')
env.Program('pulse', src)
