import numpy as np
from numpy import genfromtxt
import os
import pylab as plt
import glob

# Function definitions
def degree_heating(threshold_temperature, temp_array):
    
    return [1 if x < threshold_temperature else 0 for x in temp_array]
    
# Importing the data
files = open(os.getcwd() + "../input_data/temperatures_de Bilt_2013_fifteen_minutes.csv")

# Main loop
for temperature_file in files: 

    print temperature_file
    print temperature_file.split("/")[-1]

    # Data for temperature (hourly)
    data = genfromtxt(temperature_file, delimiter=",")

    # Temperature data is given in tenths of degrees, converting to degrees
    temperature_2012 = data / 10

    # Creating degree hours (as the data is hourly) 
    hdh_2012 = np.array(degree_heating(18, temperature_2012))
    cdh_2012 = np.array(degree_cooling(18, temperature_2012))

    # Turning degree hours into degree days by summing degree hours per 24 and dividing by 24 (taking the average)
    hdd_2012 = np.sum(hdh_2012.reshape(365, 24), axis = 1) / 24
    cdd_2012 = np.sum(cdh_2012.reshape(365, 24), axis = 1) / 24

    # As a check, also use the average daily temperature to calculate HDD and CDD
    daily_averaged_temperature_2012 = np.mean(temperature_2012.reshape(365, 24), axis = 1)
    ahdd_2012 = np.array(degree_heating(18, daily_averaged_temperature_2012))
    acdd_2012 = np.array(degree_cooling(18, daily_averaged_temperature_2012))

    plt.savetxt(os.getcwd() + "/degree_days_output/heating_degree_days_" + temperature_file.split('/')[-1], hdd_2012, fmt='%.3f')
    plt.savetxt(os.getcwd() + "/degree_days_output/cooling_degree_days_" + temperature_file.split('/')[-1], cdd_2012, fmt='%.3f')
min_x = 0
max_x = 300

plt.figure(figsize=[10,7])
plt.plot(daily_averaged_temperature_2012[min_x: max_x], 'y', label='temp 2012')
plt.plot(([20]*365)[min_x: max_x],'r--')
plt.plot(([25]*365)[min_x: max_x],'k--')
plt.plot(hdd_2012[min_x: max_x], label='HDD')
plt.plot(cdd_2012[min_x: max_x], label='CDD')

#plt.plot(ahdd_2012[min_x: max_x], label='averaged HDD')
#plt.plot(acdd_2012[min_x: max_x], label='averaged CDD')

plt.xlabel('time (days)')
plt.ylabel('degree days (deg)')
plt.title('cooling- and heating degree days')
plt.legend()

plt.show()
plt.close()

# hdh = []
# cdh = []
# total = []
# for i in range(20):
#     hdh.append( np.sum(degree_heating_hours(0 + i, temperature_2012)) )
#     cdh.append( np.sum(degree_cooling_hours(0 + i, temperature_2012)) )
#     total.append(hdh[-1]+cdh[-1])
    
# plt.figure(figsize=[10,7])
# plt.plot(hdh, label='HDH')
# plt.plot(cdh, label='CDH')
# plt.plot(total, label ='total')
# plt.legend()
# plt.show()