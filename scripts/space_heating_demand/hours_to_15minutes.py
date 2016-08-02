import numpy as np
from numpy import genfromtxt
import matplotlib.pyplot as plt
import glob
import os

def write_profile(profile, name):
    
    time_steps = 8760
    if len(profile) == time_steps:
           
        print "Writing: ", str(name)
        out_file = open(str(name),"w")
        
        for item in profile:
            for i in range(1,5):
                out_file.write(str(item) + "\n")
            
        out_file.close()
        
    else:
        print "Error! profile has " + str(len(profile)) + " lines"
        
    return

# Define the fraction of the demand that is always there
flexible_fraction = 1.0

dir_name = "../input_data/"
#filename = "space_heating_gas.csv"
#filename = "total_gas_consumption.csv"
filename = "hot_water_scenario_tool.csv"

data = genfromtxt(dir_name+filename, delimiter=',')

flexible_demand = flexible_fraction * data
        
inflexible_demand = data - flexible_demand

mini = 1500
maxi = 1600
    
plt.close()
plt.figure(figsize=(10,4))
plt.plot(data[mini:maxi], 'r--', linewidth=3.0, label="original")
plt.plot(flexible_demand[mini:maxi], label="flex")
plt.plot(inflexible_demand[mini:maxi], label="in-flex")
plt.legend()
plt.xlabel("time step (15 minutes)")
plt.ylabel("load [normalized]")
plt.show()

outfile_name = filename.split("/")[-1].split(".")[0]

# Write data to file
write_profile(flexible_demand+inflexible_demand, "../output_data/"+outfile_name+"_fifteen_minutes.csv")
