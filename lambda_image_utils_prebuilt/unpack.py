import os
import ctypes
import sys
from io import BytesIO
from zipfile import ZipFile
import requests

from safe_extractor import safe_extractor
import requests

deps_install='/tmp/'
deps_download='https://s3.amazonaws.com/lambda_image_utils_prebuilt/deps.zip'

print("Downloading '{}' into memory. If this fails, you may need to increase the memory limit.".format(deps_download))
url = requests.get(deps_download)
zipfile = ZipFile(BytesIO(url.content))

print("Unpacking in memory zip archive into '{}'.".format(deps_install))
zipfile.extractall(deps_install)

print("Recursively loading all libs from '{}'.".format(deps_install))
for d, dirs, files in os.walk(deps_install):
    for f in files:
        if f.endswith('.a'):
            continue
        try:
            ctypes.cdll.LoadLibrary(os.path.join(d, f))
        except Exception as e:
            continue

print("Inserting '{}' into python's sys.path.".format(deps_install))
sys.path.insert(0, deps_install)
