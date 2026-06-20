import faulthandler
import sys

faulthandler.enable()
faulthandler.dump_traceback_later(60, repeat=True, file=sys.stderr)

print("starting Util import", flush=True)
from python_files.Util import *
print("Util import finished", flush=True)
