# -*- coding: utf-8 -*-
"""
Created on Wed Apr 29 11:09:48 2015

@author: joris.berkhout@quintel.com & chael.kruip@quintel.com
"""

import numpy as np
from numpy import genfromtxt
import pylab as plt
import os
import space_heating_classes
reload(space_heating_classes)
 
plt.close()
 
#==============================================================================
# This script generates heating demand curves based on a temperature
# profile, solar irradiation and some simple characteristics of the house.
#==============================================================================

# Data for temperature (15 minutes)
temperatures = genfromtxt(os.getcwd() + "/../input_data/temparatures_de Bilt_2013_fiteen_minutes.csv", delimiter=" ")
       
# Solar data (15 minutes)
irradiance_in_kW = genfromtxt(os.getcwd() + "/../input_data/irradiance_in_kW_per_m_squared_maastricht.csv", delimiter=" ")

# Global constants
 
# Specs of house
floor_area = 75
window_area = 20
thermostat_temperature_day = 20
thermostat_temperature_night = 10

house = space_heating_classes.house(floor_area, 
                                window_area, 
                                thermostat_temperature_day)                          
# Print info about house
house.print_info()

# create the demand profiles
# Initialise profiles
heat_demand_profile = []

# Main loop
i = 0
for solar_heat in irradiance_in_kW:
    
    # Effect of a time-dependent thermostate:
    # Only between 08:00 and 00:00 do we heat the house
    if (i % 96) < 32:
       house.set_thermostate_temperature(thermostat_temperature_night)
    else:
       house.set_thermostate_temperature(thermostat_temperature_day)

    outside_temperature = temperatures[i]
    
    # Leak heat from the house (if it is indeed colder outside than inside) 
    # Also allow sunlight to shine in and heat the house
    house.exchange_heat_with_outside(outside_temperature, np.mean(solar_heat))
        
    # Calculate the demand
    current_heat_demand = house.get_heat_demand()
    
    if current_heat_demand > 0.0:
        heat_demand_profile.append(current_heat_demand)
    else:
        heat_demand_profile.append(0.0)

    i += 1
    
# scale the demand_profile
demand_profile = np.array(heat_demand_profile)
          
mini = 0 * 4 * 24
maxi = int(7 * 4 * 24)
plt.plot(demand_profile[mini:maxi])
plt.xlabel('time (15 minutes)')
plt.ylabel('Heat demand (kW)')
plt.show()

print "../output_data/hp_space_heating_" + str(floor_area) + "m2"
plt.savetxt("../output_data/space_heating_demand_" + str(floor_area) + "m2.csv", demand_profile, fmt='%.3f', delimiter=',') 

