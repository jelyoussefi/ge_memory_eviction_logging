#!/usr/bin/python
import re
from functools import partial
import time
import datetime
import pyudev
import pandas as pd
import matplotlib.pyplot as plt


context = pyudev.Context();
monitor = pyudev.Monitor.from_netlink(context);
monitor.filter_by('drm')

def process(props, tag, df):
	if tag in props:		
		tokens = re.findall(r"\[\s*(.*?)\s*\]", props[tag])
		if tag == "START" or tag == "RESUME":
			state = 1
		else:
			state = 0
			
		ts = tokens[0]
		#ts = time.mktime(datetime.datetime.strptime(ts,"%Y-%m-%d %H:%M:%S.%f").timetuple())
		print(ts)
		pid = tokens[1]
		row = {'datetime': ts, 'pid': int(pid), 'state': state};
		df = df.append(row, ignore_index=True)
	return df

df = pd.DataFrame(columns=['datetime', 'pid', 'state'])	

while True:	
	for device in iter(partial(monitor.poll, timeout=8), None):
	  if "change" != device.action:
	  	continue;
	  props = device.properties
	  

	  df = process(props, "START", df)
	  df = process(props, "SUSPEND", df)
	  df = process(props, "RESUME", df)
	
	if len(df) != 0 :

		break
		  
df["datetime"] = pd.to_datetime(df["datetime"])
print(df)
df.plot(x='datetime', y='state')


plt.show()
   
