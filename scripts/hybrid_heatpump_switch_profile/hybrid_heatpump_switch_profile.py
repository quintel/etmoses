import numpy as np
from numpy import genfromtxt
import os
import pylab as plt

# Function definitions
def switch_function(threshold_temperature, temp_array):
    
    return [1 if x < threshold_temperature else 0 for x in temp_array]
    
# Importing the data
file_name = "../input_data/temperatures_de Bilt_2013_fifteen_minutes.csv"
temperature_file = open(file_name)

# Data for temperature (15 minutes)
data = genfromtxt(temperature_file, delimiter=",")

# Applying the function
threshold = 4.0
switch_profile = switch_function(threshold, data)

plt.savetxt("../output_data/hhp_switch_according_to_" + file_name.split('/')[-1], switch_profile, fmt='%.3f')

min_x = 0
max_x = 5000

plt.figure(figsize=[10,7])
plt.plot(([threshold]*35040)[min_x: max_x],'r--')
plt.plot(data[min_x: max_x],'k', label='Temperature')
plt.plot(10*np.array(switch_profile[min_x: max_x]), label='HP/Gas')

plt.xlabel('time (15 minutes)')
plt.ylabel('Temperature, HP/Gas')
plt.legend()

plt.show()
plt.close()