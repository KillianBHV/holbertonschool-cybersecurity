#!/usr/bin/env python3

import os
import sys

print("euid:", os.geteuid(), file=sys.stderr)

print("[INFO] PySniffer initialized")
