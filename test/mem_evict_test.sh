#!/bin/bash

source /opt/intel/oneapi/setvars.sh --force > /dev/null

nice -n -10 ./oneAPIMemTest_lp -m 1  -t 15  &
sleep 5
nice -n -14 ./oneAPIMemTest_hp -m 0.5  -t 5 -i 1
sleep 5


