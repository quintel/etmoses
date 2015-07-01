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
reload(heat_pump_classes)
 
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
capacity_in_kW = 10

# Specs of storage tank
liters = 100
max_temperature = 40
min_temperature = thermostat_temperature_day
energy_per_liter_per_degree = 0.00116

# Output the capacity of the storage tank
max_content_in_kWh = liters * energy_per_liter_per_degree * (max_temperature - min_temperature)
print "Max content of buffer", max_content_in_kWh, "kWh"

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

def create_availability_profile(use_profile, capacity_in_kW, max_content_in_kWh):
    # This profile creates an availability profile from a use profile. The use
    # of hot water determines when the heat pump needs to start heating. The
    # output profile of this function indicates which fraction of the total 
    # storage volume of the heat pump boiler should be full

    # Calculate which fraction of the boilers capacity you can fill in 15 minute
    # 3600 is the conversion factor J / Wh  
    maximum_added_energy = (capacity_in_kW / 4.0) / max_content_in_kWh
    print maximum_added_energy

    # start at the end of the year and works backwards
    backwards_use_profile = use_profile[::-1]

    # create a backwards availability profile
    backwards_availability_profile = np.zeros(len(use_profile))

    # at the last quarter of the year, the boiler needs to contain enough energy
    # to supply the required hot water at this last quarter
    backwards_availability_profile[0] = backwards_use_profile[0]

    # using the amount of energy that can be added to the boiler per quarter,
    # we can iteratively calculate how much energy should be in the boiler at
    # the second to last quarter and so on    
    for i in range(1, len(use_profile)):
    
        required_extra_energy = backwards_availability_profile[i-1] - maximum_added_energy + backwards_use_profile[i]  
    
        if required_extra_energy > 0:
            backwards_availability_profile[i] = required_extra_energy
        else:
            backwards_availability_profile[i] =  0.0

    availability_profile = backwards_availability_profile[::-1]
    
    # Adding the demand to the extra demand
    availability_profile += use_profile
    
    return availability_profile
    
availability_profile = create_availability_profile(demand_profile, capacity_in_kW, max_content_in_kWh)
availability_profile = [x if x < 1 else 1 for x in availability_profile]
   
mini = 8 * 4 * 24
maxi = int(365 * 4 * 24)
plt.plot(demand_profile[mini:maxi])
plt.plot(availability_profile[mini:maxi])
#plt.plot(availability_profile[mini:maxi]-demand_profile[mini:maxi])
plt.xlabel('time (15 minutes)')
plt.ylabel('Fraction of buffer extracted')
plt.show()

print "../output_data/hp_space_heating_" + str(capacity_in_kW) + "kW_" + str(floor_area) + "m2_" + str(liters) + "liter"
plt.savetxt("../output_data/hp_space_heating_" + str(capacity_in_kW) + "kW_" + str(floor_area) + "m2_" + str(liters) + "liter_use.csv", demand_profile, fmt='%.3f', delimiter=',') 
plt.savetxt("../output_data/hp_space_heating_" + str(capacity_in_kW) + "kW_" + str(floor_area) + "m2_" + str(liters) + "liter_availability.csv", availability_profile, fmt='%.3f', delimiter=',') 