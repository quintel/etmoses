# -*- coding: utf-8 -*-
"""
Created on Wed Apr 29 11:09:48 2015

@author: joris.berkhout@quintel.com & chael.kruip@quintel.com
"""

import numpy as np
from numpy import genfromtxt
import pylab as plt
import os
import heat_pump_classes
reload (heat_pump_classes)
 
plt.close()
 
#==============================================================================
# This script generates load profiles for heat pumps based on a temperature
# profile and some simple characteristics of the house.
#==============================================================================
 

# Data for temperature (15 minutes)
temperatures =genfromtxt(os.getcwd() + "/../input_data/temparatures_de Bilt_2013_fiteen_minutes.csv", delimiter=" ")
       
# Solar data (15 minutes)
irradiance_in_kW = genfromtxt(os.getcwd() + "/../input_data/irradiance_in_kW_per_m_squared_maastricht.csv", delimiter=" ")

# Global constants
 
# Specs of house
floor_area = 100
window_area = 20
thermostat_temperature_day = 20
thermostat_temperature_night = 10

house = heat_pump_classes.house(floor_area, 
                                window_area, 
                                thermostat_temperature_day)                          
# Print info about house
house.print_info()

# Specs of heat-pump
capacity_in_kW = 6

# Specs of storage tank
liters = 100
max_temperature = 40
min_temperature = thermostat_temperature_day
energy_per_liter_per_degree = 0.00116

# Output the capacity of the storage tank
max_content_in_kWh = liters * energy_per_liter_per_degree * (max_temperature - min_temperature)

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
demand_profile = demand_profile / max_content_in_kWh
       
# If the tank should be more than 100% full, we expect the gas-boiler to kick in and save the day
demand_profile = [x if x < 1 else 1 for x in demand_profile]
    
filename = 'hp_sh_availability_profile.csv'
#plt.savetxt(availability_filename, availability_profile, fmt='%.3f', delimiter=',')    
    
mini = 0 * 4 * 24
maxi = 30 * 4 * 24
plt.plot(demand_profile[mini:maxi])
plt.xlabel('time (15 minutes)')
plt.ylabel('Fraction of buffer extracted')
plt.show()

plt.savetxt("/Users/kruip/Dropbox (Quintel)/shared_with_partners/201405_alliander_model_shared/profiles/heat_pumps/space_heating_10kW_day_night/hp_space_heating_10kW_100m2_100liter.csv", demand_profile, fmt='%.3f', delimiter=',') 