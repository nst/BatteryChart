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

capacities = [row[4] for row in data]
voltages = [row[6] for row in data]

fig = plt.figure()

plt.title("iPhone 5 Battery")

axes_1 = fig.add_subplot(111)
lines_1 = axes_1.plot(hours, capacities, '-r', label="Capacity")

axes_2 = axes_1.twinx()
lines_2 = axes_2.plot(hours, voltages, '-b', label="Voltage")

lines = lines_1 + lines_2
labels = [l.get_label() for l in lines]

axes_1.legend(lines, labels, loc="lower left")
axes_1.grid()
axes_1.set_xlabel("Time [hours]")
axes_1.set_ylabel("Capacity [mAh]")
axes_1.set_ylim(0, 1500)
axes_1.set_xticks([i for i in range(11)])

axes_2.set_ylabel("Voltage")
axes_2.set_ylim(3300, 4300)
axes_2.set_xticks([i for i in range(11)])

plt.savefig('battery_2.png')
