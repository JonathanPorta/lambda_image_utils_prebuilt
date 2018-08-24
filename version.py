from __future__ import print_function
import semver, os

version_file = './VERSION'

with open(version_file, encoding='utf-8') as f:
    v = f.read()

v=v.strip()

nv = semver.bump_patch(v)

print('Bumping version from {} to {}...\n'.format(v, nv))
print(nv, file=open(version_file, 'w'))
