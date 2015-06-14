# -*- coding: utf-8 -*-
"""
Created on Wed Apr 29 11:09:48 2015

@author: jorisberkhout
"""

#==============================================================================
# This script can be used to generate typical domestic hot water (DHW) profiles
# for a period of one year and time steps of 15 minutes. The script is based in
# great part on Realistic Domestic Hot-Water Profiles in Different Time Scales,
# Jordan (2001). This study assumes a daily average DHW use of 200 liters and
# distinguishes four types of DHW consumption, each with an associated volume
# and average daily occurence:
#
# type A: short load (1 liter per event, 28 occurences per day)
# type B: medium load (6 liter per event, 12 occurences per day)
# type C: bath (140 liter per event, 0.143 occurences per day (once a week))
# type D: shower (40 liter per event, 2 occurences per day)
#
# According to Jordan (2001), the duration of each of these types is shorter 
# than 15 minutes (i.e. the time resolution of our simulation). Hence we 
# decided to only model the probability that an event occurs within each 15 
# minute time step and assign the entire volume of that event to that 15 minute
# bin. The probability of each type of event varies throughout the year (i.e.
# slightly more DHW consumption in winter), throughout the week (more in the
# weekend) and throughout the day (no DHW consumption during the night).
# 
# The script returns randomly generated profiles with a time resolution of 15 
# minutes. To match the needs of the ETM these exported profiles are scaled to
# the maximal storage volume of the electric boiler used in the ETM for P2H.
# (i.e. 9.3 kWh)
#==============================================================================

import numpy as np
import pylab as plt
#import heat_pump_classes
#reload (heat_pump_classes)
from numpy import genfromtxt
 
plt.close()
 
 
#==============================================================================
# This script generates load profiles for heat pumps based on a temperature
# profile and some simple characteristics of the house.
#==============================================================================
 
# Global constants
year = 2013
kWh_per_degree_day = 3.0
days_per_hour = 0.04166666667
 
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
print "Max energy content of tank:", max_content_in_kWh, " kWh"
 
# Data
temperature_data =genfromtxt("/Users/jorisberkhout/Dropbox (Quintel)/201405_alliander_model_shared/profiles/bilt_2013_T.txt", delimiter=" ")
 
# Extract only temperature data and converting to degrees C
temperatures = np.array(zip(*temperature_data)[2]) / 10.0       
 
# How many kWh do I have to heat for in this hour?
def heat_demand(degree_days):
    return degree_days * kWh_per_degree_day
 
# Return the degree days for this hour
def degree_days(outside_temperature, thermostat_temperature):
    if outside_temperature < thermostat_temperature:
        return days_per_hour * (thermostat_temperature - outside_temperature)
    else:
        return 0.0
        
def create_availability_profile(use_profile):
    # This profile creates an availability profile from a use profile. The use
    # of hot water determines when the heat pump needs to start heating. The
    # output profile of this function indicates which fraction of the total 
    # storage volume of the heat pump boiler should be full

    # Calculate which fraction of the boilers capacity you can fill in 15 minute
    # 3600 is the conversion factor J / Wh    
    #added_energy = capacity_in_kW / 4.0  / max_content_in_kWh
    added_energy = 0.028   
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

demand_profile = []
 
# Main loop
thermostat_temperature = 20.0
 
#i = 0
for temperature in temperatures:
     
#    i += 1
#    if i > 50:
#        sys.exit(0)
 
 
    # Leak some heat from the tank
#    storage_tank.leak()
     
    # Calculate degree days for this hour
    current_degree_days = degree_days(temperature, thermostat_temperature)
     
    # Calculate the demand
    current_heat_demand = heat_demand(current_degree_days)
    
    demand_profile.append(current_heat_demand)

# scale the demand_profile
demand_profile = np.array(demand_profile)
demand_profile = demand_profile / max_content_in_kWh

# Global variables


    
# main loop    
    
    
use_filename = 'dhw_use_profile.csv'
#plt.savetxt(use_filename, pattern, fmt='%.3f', delimiter=',')    
    
# calculate the availability profile from the use profile
availability_profile = create_availability_profile(demand_profile)    
    
filename = 'dhw_availability_profile.csv'
#plt.savetxt(availability_filename, availability_profile, fmt='%.3f', delimiter=',')    
    
    
plt.plot(demand_profile)
plt.plot(availability_profile)
    
#plt.plot(availability_profile)

# bin all events per day and display these
#plt.plot(pattern.reshape(-1, 96).sum(axis=1), 'k-')
#plt.xlabel('time (days)')
#plt.ylabel('daily energy use for DHW consumption (kWh)')
#plt.title('pattern ' + str(j+1))

plt.show()