# -*- coding: utf-8 -*-
"""
Created on Wed Apr 29 11:09:48 2015
Modified on Fri Jul 29 12:00:00 2016        

@author: joris.berkhout@quintel.com & chael.kruip@quintel.com
"""

#==============================================================================
# This script is used to generate typical time profiles for domestic hot water
# (DHW) demand. These profiles are generated for a period of one year and time
# resolution of 15 minutes. The script is based in great part on the study 
# `Realistic Domestic Hot-Water Profiles in Different Time Scales` by Jordan
# (2001). Within this study the DHW demand is divided in four categories or
# types of events:
#
# type A: short load (washing hands, washing food)
# type B: medium load (doing the dishes, hot water for cleaning)
# type C: bath
# type D: shower
#
# Jordan (2001) defines probability curves for each type of events: these
# curves specify the probability of such an event to occur at every 15 minute
# time step. Combined with a typical volume per type of event and a typical
# number of occurences per day, these probability curves are used to generate
# random DHW demand profiles. We have refined the method described in the study
# in three ways:
#
# 1. we have adapted the volumes and occurences to the Dutch situation as derived
#    from other sources
#    
#    | type | volume per event | daily occurence per person |
#    | ---- | ---------------- | -------------------------- |
#    | A    | 1                | 5                          |
#    | B    | 9                | 1                          |
#    | C    | 120              | 0.143 *                    |
#    | D    | 50               | 1                          |
#
#    * once a week provided that the household has a bath, which we assume is true
#      for 1 in every 7 households
# 2. we have added the option to include events of type C (bath) in the DHW
#    demand profile or not; these events represent relatively high hot water
#    demands resulting in 'spiky' profiles which are not representative for most
#    households as only 1 in 7 owns a bath 
# 3. we have made it possible to adapt the profiles to represent households
#    with different numbers of people in it; some events happen more often when
#    this number of people increases (e.g. showers), other events increase in volume
#    (e.g. doing the dishes).
# 
# In addition we make the following two assumptions:
# 
# 1. we assume that all events occur entirely within a single timestep.
# 2. we assume that all types of events require water at the same temperature;
#    this means that the DHW demand in kWh is proportional to the DWH in liters.
#    The script returns a normalized DWH demand profile that is scaled when used
#    in ETMoses or ETModel. 
#
# The script returns randomly generated, normalized DHW demand profiles named
# 'DHW_demand_profile_<n>p_<b>_<i>.csv'
# where <n> is the number of persons in the household, <b> is bath or no_bath
# and <i> is the number of the profile. In order to make sure that the same
# profile can be recreated, <i> is also used as a random seed while
# generating the profile.
# The script also returns a aggregated profile which takes into account the
# average number of people per household and the fact that only 1 in around 7
# households has a bath.
#==============================================================================

import numpy as np
import pylab as plt

plt.close()

# Global variables

# volumes per type of event
volume_A_person = 1
volume_B_person = 9
volume_C_person = 120
volume_D_person = 50

# daily occurence per type of event
occ_A_person = 10
occ_B_person = 1
occ_C_person = 0.143
occ_D_person = 1

# All profiles are generated with a time resolution of 15 minutes

quarters = np.arange(0,35040.,1.)

# The code below is used to reconstruct the probability functions for each type of event;
# this is our best effort to reproduce the curves used in Jordan (2001)

def gauss_function(x, a, x0, sigma):
    return a*np.exp(-(x-x0)**2/(2*sigma**2))

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
 
# Create individual DHW demand profile
def individual_DHW_profile(n, b, i):

    # Scale 
    occ_A_household = occ_A_person * n
    occ_B_household = occ_B_person
    occ_C_household = occ_C_person * n
    occ_D_household = occ_D_person * n

    volume_A_household = volume_A_person
    volume_B_household = volume_B_person * n
    volume_C_household = volume_C_person
    volume_D_household = volume_D_person

    # Create empty patterns
    pattern_A = np.zeros(len(prob_year_A))
    pattern_B = np.zeros(len(prob_year_B))
    pattern_C = np.zeros(len(prob_year_C))
    pattern_D = np.zeros(len(prob_year_D))

    np.random.seed(i)

    for j in range(0, len(pattern_A)):
        
        # construct the random pattern for each type of event by taking onto account
        # their probability, the number of events per day and the volume per event    
        pattern_A[j] = volume_A_household * np.random.choice((0,1),p=[1-prob_year_A[j]*occ_A_household*365, prob_year_A[j]*occ_A_household*365])
        pattern_B[j] = volume_B_household * np.random.choice((0,1),p=[1-prob_year_B[j]*occ_B_household*365, prob_year_B[j]*occ_B_household*365])
        pattern_C[j] = volume_C_household * np.random.choice((0,1),p=[1-prob_year_C[j]*occ_C_household*365, prob_year_C[j]*occ_C_household*365])
        pattern_D[j] = volume_D_household * np.random.choice((0,1),p=[1-prob_year_D[j]*occ_D_household*365, prob_year_D[j]*occ_D_household*365])

    pattern = pattern_A + pattern_B + b * pattern_C + pattern_D

    return pattern / sum(pattern)

# Create aggregated DHW demand profile
def aggregated_DHW_profile(n):

    # Scale 
    occ_A_household = occ_A_person * n
    occ_B_household = occ_B_person
    occ_C_household = occ_C_person * n
    occ_D_household = occ_D_person * n

    volume_A_household = volume_A_person
    volume_B_household = volume_B_person * n
    volume_C_household = volume_C_person
    volume_D_household = volume_D_person

    # Create empty patterns
    pattern_A = np.zeros(len(prob_year_A))
    pattern_B = np.zeros(len(prob_year_B))
    pattern_C = np.zeros(len(prob_year_C))
    pattern_D = np.zeros(len(prob_year_D))

    # construct the random pattern for each type of event by taking onto account
    # their probability, the number of events per day and the volume per event    
    pattern_A = volume_A_household * prob_year_A*occ_A_household*365
    pattern_B = volume_B_household * prob_year_B*occ_B_household*365
    pattern_C = volume_C_household * prob_year_C*occ_C_household*365 * 1 / 7
    pattern_D = volume_D_household * prob_year_D*occ_D_household*365

    pattern = pattern_A + pattern_B + pattern_C + pattern_D

    return pattern / sum(pattern)

# main loop 

# individual profiles

n = 3
b = 0
i = 3

if b == 0:
    bath = 'no_bath_'
elif b == 1:
    bath = 'bath_'

profile = individual_DHW_profile(n, b, i)
use_filename = '../output_data/DHW_demand_profile_' + str(n) + 'p_' + bath + str(i) + '.csv'

# aggregated profiles

# # average number of people per household
# n = 2.2
# profile = aggregated_DHW_profile(n)

# use_filename = '../output_data/DHW_demand_profile_aggregated.csv'

print use_filename

plt.savetxt(use_filename, profile, fmt='%.3e', delimiter=',')

plt.plot(profile)  
plt.show()

# # Appendix: plot probability curves for documentation

# # probability throughout the day

# plt.figure(1)

# plt.plot(prob_day_AB / sum(prob_day_AB), label="types A and B")
# plt.plot(prob_day_C / sum(prob_day_C), label="type C")
# plt.plot(prob_day_D / sum(prob_day_D), label="type D")

# plt.xlim(0, 96)
# plt.ylim(0, max(max(prob_day_AB / sum(prob_day_AB)), max(prob_day_C) / sum(prob_day_C), max(prob_day_D) / sum(prob_day_D)) * 1.1)

# plt.title("probability throughout the day")
# plt.xlabel("time (15 min)")
# plt.ylabel("probability")
# plt.legend(loc=1)

# # probability throughout the week

# plt.figure(2)

# plt.step([0,1,2,3,4,5,6], prob_week_ABD/sum(prob_week_ABD), label="types A, B and D")
# plt.step([0,1,2,3,4,5,6], prob_week_C/sum(prob_week_C), label="type C")

# plt.xlim(0, 6)
# plt.ylim(0, max(max(prob_week_ABD / sum(prob_week_ABD)), max(prob_week_C) / sum(prob_week_C)) * 1.1)

# plt.title("probability throughout the week")
# plt.xlabel("time (days)")
# plt.ylabel("probability")
# plt.legend(loc=2)

# # probability throughout the year

# plt.figure(3)

# plt.plot(prob_year_ABCD / sum(prob_year_ABCD), label="types A, B, C and D")

# plt.xlim(0, 35040)
# plt.ylim(0, max(prob_year_ABCD / sum(prob_year_ABCD)) * 1.1)

# plt.title("probability throughout the year")
# plt.xlabel("time (15 min)")
# plt.ylabel("probability")
# plt.legend(loc=4)

# plt.show()