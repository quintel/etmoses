import numpy as np
from numpy import genfromtxt
import matplotlib.pyplot as plt
import random

random.seed(33)

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
    
def weighted_choice(choices):
    
   total = sum(w for c, w in choices)
   r = random.uniform(0, total)
   upto = 0
   for c, w in choices:
      if upto + w > r:
         return c
      upto += w
   assert False, "Shouldn't get here"

class Technology:
    
    def __init__(self, values):
        self.name = values[0]
        self.typical_capacity = values[1]
        self.duration = values[2]
        self.occurences_per_year = values[3]
        self.flexible = values[4]
        self.allowed_delay = values[5]
        
    def print_info(self):
        print "Name:", self.name
        print "Ocurrences per year:", self.occurences_per_year
        print "Typical duration:", self.duration, "* 15 minutes"
        print "Typical capacity:", self.typical_capacity, "kW"
        print "Flexible?", self.flexible == 1
        print "Allowed delay", self.allowed_delay
        print ""

# Defining technologies
# Data taken from https://www.dropbox.com/s/4ph06uwadkujcu5/20150616_base_load_specs.xlsx?dl=0
vacuum_cleaner = Technology(["Vacuum cleaner", 0.75, 4, 96, 0, 0])
washing_machine = Technology(["Washing machine", 2.75, 8, 240, 1, 3])
airconditioner = Technology(["Air conditioner", 2.5, 8, 160, 0, 0])
heater = Technology(["heater", 1.5, 2, 240, 0, 0])
dish_washer = Technology(["Dish washer", 1.2, 8, 240, 1, 3])
dryer = Technology(["Dryer", 2.75, 8, 64, 1, 3])
kitchen_tools = Technology(["Kitchen tools", 0.75, 1, 770, 0, 0])
stove = Technology(["Stove", 2.0, 1, 200, 0, 0])

technologies = [vacuum_cleaner, washing_machine, airconditioner, heater, dish_washer, dryer, kitchen_tools, stove]

# Dividing the peaks in two classes based on capacity
tech_choices_low= []
tech_choices_high = []

# For now, we use 2kW as the dividing capacity
threshold_capacity = 2.0

# Filling the choice arrays
for technology in technologies:
    if technology.typical_capacity <= threshold_capacity:
        tech_choices_low.append([technology, technology.occurences_per_year])
    else:
        tech_choices_high.append([technology, technology.occurences_per_year])
        

lower_threshold_capacity = 0.5 #kW
mimimal_peak_capacity = 0.5 #kW

for j in range(1,76):
    
    # Main loop
    flexible_demand = [0]
    peak_mode = False
    current_peak_hight = 0
    base_level = 0
    
    file_name = "/Users/kruip/Dropbox (Quintel)/shared_with_partners/201405_alliander_model_shared/profiles/base_load/anonimous_smart_meter_data/anonimous_base_load_not_normalized_"+str(j)+".csv"
    data = genfromtxt(file_name, delimiter=',')
    data = 4.0 * data / 1000.0 # converting from Wh/15 min to kW
    
    
    for i in range(1, len(data)):
        
        current_load = data[i]    
        previous_load = data[i - 1]
        jump = current_load - previous_load
        
        if current_load <= lower_threshold_capacity:
            peak_mode = False
    
        elif jump < 0 and np.abs(jump) >= 0.7 * current_peak_hight:
            peak_mode = False
            
        elif jump < 0 and current_load <= base_level:
            peak_mode = False
    
        elif jump > mimimal_peak_capacity:
            peak_mode = True
            current_peak_hight = jump
            base_level = previous_load
            
            if current_peak_hight <= mimimal_peak_capacity:
            
                selected_technology = weighted_choice(tech_choices_low)
                #print selected_technology.name
            
            elif current_peak_hight > mimimal_peak_capacity:
                
                selected_technology = weighted_choice(tech_choices_high)
                #print selected_technology.name
        
        # Are we currently in a peak?
        if peak_mode:
    
            # Is the selected technology flexible?
            if selected_technology.flexible:
           
                flexible_demand.append(current_load)
       
            else:
                
                flexible_demand.append(0)
        else:
            
            flexible_demand.append(0)
            
    inflexible_demand = data - flexible_demand
    
#    mini = 1500
#    maxi = 1600
#        
#    plt.close()
#    plt.figure(figsize=(10,7))
#    plt.plot(data[mini:maxi], 'r--', linewidth=3.0, label="original")
#    plt.plot(flexible_demand[mini:maxi], label="flex")
#    plt.plot(inflexible_demand[mini:maxi], label="in-flex")
#    plt.legend()
#    plt.show()
    
    # Write data to file
    write_profile(flexible_demand, "/Users/kruip/Dropbox (Quintel)/shared_with_partners/201405_alliander_model_shared/profiles/base_load/anonimous_smart_meter_data/anonimous_base_load_"+str(j)+"_flex.csv")
    write_profile(inflexible_demand, "/Users/kruip/Dropbox (Quintel)/shared_with_partners/201405_alliander_model_shared/profiles/base_load/anonimous_smart_meter_data/anonimous_base_load_"+str(j)+"_inflex.csv")