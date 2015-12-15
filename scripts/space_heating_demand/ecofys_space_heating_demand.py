import numpy as np
from numpy import genfromtxt
import matplotlib.pyplot as plt
import os

time_steps = 8760

file_name = "../input_data/Ecofys_ECN_heating_profiles.csv"

data = zip(*genfromtxt(file_name, delimiter=','))

names = ["tussenwoning_laag", "tussenwoning_midden", "tussenwoning_hoog", 
        "hoekwoning_laag", "hoekwoning_midden", "hoekwoning_hoog", 
        "twee_onder_een_kapwoning_laag", "twee_onder_een_kapwoning_midden", "twee_onder_een_kapwoning_hoog", 
        "appartement_laag", "appartement_midden", "appartement_hoog", 
        "vrijstaande_woning_laag", "vrijstaande_woning_midden", "vrijstaande_woning_hoog"]

profiles = []
totals = []

counter = 0
for profile in data:
    
    if len(profile) == time_steps:

        profiles.append(profile)
        totals.append(np.sum(profile))
           
        print "Writing: ", names[counter]+".csv"
        out_file = open("../output_data/"+names[counter]+".csv","w")
        
        for item in profile:
            for i in range(4):
                out_file.write(str(item) + "\n")
            
        out_file.close()
        
    else:
        print "Error! profile #"+str(counter)+" has "+ str(len(profile)) + " lines"
        
    counter += 1


print totals

plt.close()
plt.figure(figsize=(19, 7))

mini = 0
maxi = 24 * 7
for name,profile in zip(names,profiles):

    #if "appartement" in name:
    #plt.plot(profile[mini:maxi]/np.sum(profile),linewidth=1.0, label=name)  
    plt.plot(profile[mini:maxi],linewidth=1.0, label=name)  

plt.xlabel('time (hours)')
plt.ylabel('kW')
plt.legend()
plt.show()