#!/usr/bin/env python

import numpy
from matplotlib import pyplot as plt
import dateutil

# 0. _date
# 1. _statusBarBatteryCapacity
# 2. _level
# 3. _deviceBatteryLevel
# 4. _currentCapacity
# 5. _maxCapacity
# 6. _rawVoltage
# 7. _ioKitLevel

data = numpy.recfromcsv('battery.csv', delimiter=',')

t0 = dateutil.parser.parse(data[0][0])
hours = [(dateutil.parser.parse(row[0]) - t0).total_seconds() / 60 / 60 for row in data]

status_bar_charges = [row[1] for row in data]
osd_battery_charges = [row[2] for row in data]
uidevice_charges = [row[3] for row in data]
iokit_charges = [row[7] for row in data]
#ratio = [100.0 * row[4] / row[5] for row in data]

fig = plt.figure()

plt.title("iPhone 5 Battery")

plt.plot(hours, status_bar_charges, '-r', label="Status Bar")
plt.plot(hours, osd_battery_charges, '-g', label="OSDBattery")
plt.plot(hours, uidevice_charges, '-k', label="UIDevice")
plt.plot(hours, iokit_charges, '-b', label="IOKit")
#plt.plot(hours, ratio, '-y', label="OSDBattery Ratio")

plt.legend(loc="lower left")
plt.xlabel("Time [hours]")
plt.xticks([i for i in range(11)])
plt.ylabel("Charge [%]")
plt.ylim(0, 100)
plt.grid()

plt.savefig('battery_1.png')
