import numpy as np
from numpy import genfromtxt
import matplotlib.pyplot as plt
import glob
import os

def write_profile(profile, name):
    
    time_steps = 8760 * 4
    if len(profile) == time_steps:
           
        print "Writing: ", str(name)
        out_file = open(str(name),"w")
        
        for item in profile:
            out_file.write(str(item) + "\n")
            
        out_file.close()
        
    else:
        print "Error! profile has " + str(len(profile)) + " lines"
        
    return

# Define the fraction of the demand that is flexible
flexible_fraction = 0.1

dir_name = "../input_data/"
for filename in glob.glob(os.path.join(dir_name, 'edsn*.csv')):
    
    
    data = genfromtxt(filename, delimiter=',')
    
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
    write_profile(flexible_demand, "../output_data/"+outfile_name+"_flex.csv")
    write_profile(inflexible_demand, "../output_data/"+outfile_name+"_inflex.csv")