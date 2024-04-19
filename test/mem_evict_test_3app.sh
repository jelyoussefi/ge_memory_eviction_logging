#!/bin/bash

source /opt/intel/oneapi/setvars.sh --force > /dev/null

nice -n -10 ./oneAPIMemTest_lp -m 1  -t 25  &
sleep 5
nice -n -12 ./oneAPIMemTest_mp -m 0.8  -t 15 -i 2 &
sleep 5
nice -n -14 ./oneAPIMemTest_hp -m 0.5  -t 5 -i 1
sleep 10


