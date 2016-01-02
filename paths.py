#!/usr/bin/env python

import os
import sys

# system paths
## file must be in project root
ROOT_PATH = os.path.dirname(os.path.realpath(__file__))
BIN_PATH = os.path.join(ROOT_PATH, 'bin')
SRC_PATH = os.path.join(ROOT_PATH, 'src')
SERV_PATH = os.path.join(ROOT_PATH, 'service')
## set system path to the root directory
sys.path.append(ROOT_PATH)
## set system path to the bin directory
sys.path.append(BIN_PATH)
## set system path to the src directory
sys.path.append(SRC_PATH)
## set system path to the service directory
sys.path.append(SERV_PATH)
