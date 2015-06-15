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
 
# Global constants
 
# Specs of heat-pump
capacity_in_kW = 3
 
# Specs of storage tank
leakage_fraction_per_hour = 0.02
liters = 300
max_temperature = 90
min_temperature = 30
energy_per_liter_per_degree = 0.00116
 
# Output the capacity of the storage tank
max_content_in_kWh = liters * energy_per_liter_per_degree * max_temperature
 
# Data
temperature_data =genfromtxt(os.getcwd() + "/../input_data/bilt_2013_T.txt", delimiter=" ")
 
# Extract only temperature data and converting to degrees C
temperatures = np.array(zip(*temperature_data)[2]) / 10.0       
 
# Solar data
irradiance_data = genfromtxt(os.getcwd() + "/../input_data/irradiance_in_watt_per_m_squared_maastricht.csv", delimiter=" ")
irradiance_in_kW = irradiance_data / 1000.0

# Specs of house
floor_area = 100
window_area = 20
thermostat_temperature = 20

house = heat_pump_classes.house(floor_area, 
                                window_area, 
                                thermostat_temperature)                          
# Print info about house
house.print_info()

# This function creates an 'availability profile' from a 'use profile'. 
# 
# Input: use profile (the use of hot water as a function of time) [fraction of storage tank for every 15 minutes]
# Output: availability profile (which fraction of the total storage volume of the heat pump boiler should be full for every 15 minutes)
# [fraction of storage tank for every 15 minutes]
#
def create_availability_profile(use_profile):

    # Calculate which fraction of the boilers capacity you can fill in 15 minute
    # 3600 is the conversion factor J / Wh    
    time_steps_per_hour = 4.0 # currently we work with 15 minute intervals
    added_energy = capacity_in_kW / time_steps_per_hour / max_content_in_kWh
    print added_energy

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
    
        required_energy = backwards_availability_profile[i-1] - added_energy + backwards_use_profile[i]  
    
        if required_energy >= 0:
            backwards_availability_profile[i] = required_energy
        else:
            backwards_availability_profile[i] = 0

    availability_profile = backwards_availability_profile[::-1]
    
    return availability_profile
 
# create the demand profiles

# Initialise profiles
heat_demand_profile = []


# Main loop
i = 0
for temperature in temperatures:
    
    i += 1
    
    # Effect of a time-dependent thermostate:
    # Only between 08:00 and 00:00 to we heat the house
    #if 8 < (i % 24):
    #   temperature = thermostat_temperature

    # Leak heat from the house (if it is indeed colder outside than inside) 
    # Also allow sunlight to shine in and heat the house
    house.exchange_heat_with_outside(temperature, np.mean(irradiance_in_kW[4*i:4*i+4]))
        
    # Calculate the demand
    current_heat_demand = house.get_heat_demand()
    
    if current_heat_demand > 0.0:
        heat_demand_profile.append(current_heat_demand)
    else:
        heat_demand_profile.append(0.0)

# scale the demand_profile
demand_profile = np.array(heat_demand_profile)
demand_profile = demand_profile / max_content_in_kWh
    
# calculate the availability profile from the use profile
availability_profile = create_availability_profile(demand_profile)    
    
filename = 'hp_sh_availability_profile.csv'
#plt.savetxt(availability_filename, availability_profile, fmt='%.3f', delimiter=',')    
    
plt.plot(demand_profile)
plt.plot(availability_profile)
    
# bin all events per day and display these
#plt.plot(pattern.reshape(-1, 96).sum(axis=1), 'k-')
#plt.xlabel('time (days)')
#plt.ylabel('daily energy use for DHW consumption (kWh)')
#plt.title('pattern ' + str(j+1))

plt.show()