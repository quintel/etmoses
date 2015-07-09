# -*- coding: utf-8 -*-
"""
Created on Wed Apr 29 11:09:48 2015

@author: joris.berkhout@quintel.com & chael.kruip@quintel.com
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
# The script returns two types of profiles:
#- use profiles: randomly generated profiles with a time resolution of 15. To 
#  match the needs of ETMoses these exported profiles are scaled to the maximal
#  storage volume of the boiler used in ETM for P2H
#- availability profiles: the profiles indicate how full the boiler has to be
#  in order to meet future demands. The profiles are derived from the use
#  profile by and are also expressed as a fraction of the maximal storage volume
#==============================================================================

import numpy as np
import pylab as plt

plt.close()

# Global variables

# volumes per type of event
volume_A = 1
volume_B = 6
volume_C = 140
volume_D = 40

# daily occurence per type of event
occ_A = 28
occ_B = 12
occ_C = 0.143
occ_D = 2

# The annual energy demand for DHW in The Netherlands in 2012
annual_energy_demand_DHW = 80e15 # Joule

# These numbers come from the ETM
number_of_inhabitants = 16730348
inhabitants_per_household = 2.2

daily_energy_demand_DHW_per_household = annual_energy_demand_DHW / 365 / number_of_inhabitants * inhabitants_per_household

# From Jordan (2001)
daily_DHW_volume = 200 # liters

# conversion from liters to energy
DHW_liters_to_energy = daily_energy_demand_DHW_per_household / daily_DHW_volume


# From the ETM, see https://github.com/quintel/etdataset/issues/599#issuecomment-98747401
specific_heat_H20 = 4.186 # Joule / gram / degrees
P2H_boiler_volume = 100 # liters
temp_diff = 95 - 15 # degrees

# HP capacity
capacity = 10000 #W
COP = 3.0
effective_capacity = capacity * COP

# The factor 1000 is to convert from liters to grams
P2H_storage_volume = specific_heat_H20 * P2H_boiler_volume * 1000 * temp_diff # Joule


def gauss_function(x, a, x0, sigma):
    return a*np.exp(-(x-x0)**2/(2*sigma**2))

quarters = np.arange(0,35040.,1.)

# The probability per year follows a cosine function with an amplitude of 10%.
# This probability function is the same for a types of events

prob_year_ABCD = 0.5 + 0.05 * np.cos((quarters/len(quarters) - 45./365 )*2*np.pi) 

# All types of events have an increasing probability of happening in the weekend
# Type C (bath) follows its own probability
# As 2013 started on a Tuesday, I shifted the values shown in Figure 1.5 of 
# Jordan (2001)

prob_week_ABD = np.array([0.95, 0.95, 0.95, 0.98, 1.09, 1.13, 0.95])
prob_week_C = np.array([0.50, 0.50, 0.50, 0.80, 1.90, 2.30, 0.50])

# Each type of event follows its own probablity function during the week. I have
# recreated the probability functions shown in Figure 1.6 of Jordan (2001) below.

# Type A and B
prob_day_AB = np.zeros(96)

for i in range(5*4, 23*4):
    prob_day_AB[i] = 1/18.

# Type C
prob_day_C = np.zeros(96)

for j in range(7*4, 23*4):
    
    prob_day_C[j] = gauss_function(j, 0.06, 15*4., 20.)
    
for k in range(17*4, 21*4):
    
    prob_day_C[j] = gauss_function(j, 0.22, 19*4., 5)

# Type D
prob_day_D = np.zeros(96)

for k in range(5*4, 9*4):

    prob_day_D[k] = gauss_function(k, 0.25, 7*4., 4.)
    
for k in range(9*4, 18*4):
    
    prob_day_D[k] = 0.02
    
for k in range(18*4, 21*4):
    
    prob_day_D[k] = gauss_function(k, 0.085, 19.5*4., 4.)
    
for k in range(21*4, 23*4):
    
    prob_day_D[k] = 0.02


# The probability for an event to happen is prob_year * prob_week * prob_day
# The following function can be used to construct the probability function for 
# an entire year with time steps of 15 minutes

def annual_probability_curve(prob_day, prob_week, prob_year):
    
    annual_probability = np.zeros(len(prob_year))    
    
    for i in range(0, len(prob_year)):
                
        day_of_week = ( i / 96 ) % 7
        hour_of_day = i % 96
        
        annual_probability[i] = prob_year[i] * prob_week[day_of_week] * prob_day[hour_of_day]
        
    # return the normalized probability function
    return annual_probability / sum(annual_probability)     
            
# Create the probabilities
prob_year_A = annual_probability_curve(prob_day_AB, prob_week_ABD, prob_year_ABCD)
prob_year_B = annual_probability_curve(prob_day_AB, prob_week_ABD, prob_year_ABCD)
prob_year_C = annual_probability_curve(prob_day_C, prob_week_C, prob_year_ABCD)
prob_year_D = annual_probability_curve(prob_day_D, prob_week_ABD, prob_year_ABCD)

def create_availability_profile(use_profile):
    # This profile creates an availability profile from a use profile. The use
    # of hot water determines when the heat pump needs to start heating. The
    # output profile of this function indicates which fraction of the total 
    # storage volume of the heat pump boiler should be full

    # Calculate which fraction of the heat pumps capacity you can fill in 15 minute
    # 3600 is the conversion factor J / Wh  
    maximum_added_energy = (effective_capacity / 4.0) * (3600 / P2H_storage_volume)

    # start at the end of the year and works backwards
    backwards_use_profile = use_profile[::-1]

    # create a backwards availability profile
    backwards_availability_profile = np.zeros(len(pattern))

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
    
# main loop 
for j in range(0,10):

    pattern_A = np.zeros(len(prob_year_A))
    pattern_B = np.zeros(len(prob_year_B))
    pattern_C = np.zeros(len(prob_year_C))
    pattern_D = np.zeros(len(prob_year_D))

    np.random.seed(j)

    for i in range(0, len(pattern_A)):
        
        # construct the random pattern for each type of event by taking onto account
        # their probability, the number of events per day and the volume per event    
        pattern_A[i] = volume_A * np.random.choice((0,1),p=[1-prob_year_A[i]*occ_A*365, prob_year_A[i]*occ_A*365])
        pattern_B[i] = volume_B * np.random.choice((0,1),p=[1-prob_year_B[i]*occ_B*365, prob_year_B[i]*occ_B*365])
        pattern_C[i] = volume_C * np.random.choice((0,1),p=[1-prob_year_C[i]*occ_C*365, prob_year_C[i]*occ_C*365])
        pattern_D[i] = volume_D * np.random.choice((0,1),p=[1-prob_year_D[i]*occ_D*365, prob_year_D[i]*occ_D*365])

    # add all patterns to obtain a pattern in liters
    pattern = pattern_A + pattern_B + pattern_C + pattern_D
        
    # calculate pattern in energy terms
    pattern = pattern * DHW_liters_to_energy
    
    # calculate the pattern in relative terms by dividing by the maximum storage volume of the P2H boiler
    pattern = pattern / P2H_storage_volume
    
    use_filename = '../output_data/dhw_use_profile_' + str(j+1) + '.csv'
    plt.savetxt(use_filename, pattern, fmt='%.3f', delimiter=',')    

    # calculate the availability profile from the use profile
    availability_profile = create_availability_profile(pattern)    
    
    availability_filename = '../output_data/dhw_availability_profile_' + str(j+1) + '.csv'
    plt.savetxt(availability_filename, availability_profile, fmt='%.3f', delimiter=',')  
 
    mini = 0
    maxi = 8760 * 4
    x = np.arange(mini,maxi)
    plt.step(x,pattern[mini:maxi],linewidth=3.0)  
    plt.step(x,availability_profile[mini:maxi])
    plt.xlabel('time (15 minutes steps)')
    plt.ylabel('daily energy use for DHW consumption (fraction of tank)')
    plt.title('pattern ' + str(j+1))
    plt.show()