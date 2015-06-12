# -*- coding: utf-8 -*-
"""
Created on Thu Feb 26 16:41:09 2015

@author: jorisberkhout
"""

import numpy
from pylab import *
import random
import datetime

#random.seed(18)

#==============================================================================
# This script generates 33 different EV availability profiles for 11 different 
# drivers and 3 different charging powers. We assume that each driver uses his 
# car to commute to work on workdays and to go to other activities on both 
# weekend days. The commute to work follows the same pattern every workday
# (i.e. the same departure and arrival times and distance travelled). In order 
# to avoid the charging to start on exactly the same time every workday, we add
# a random time to the departure and arrival times in the interval [-30, 30]
# minutes. We do the same for weekend days. For weekend days we pick a random
# trip from the other data. Both the work and othe data come from table D.1 in
# the thesis of Remco Verzijlbergh. Finally we take into account (public) 
# holidays and sick leave by assuming that the EV stays at home for about 18% 
# of the work days, selected randomly.
#
# The availability profiles are used to determine the absolute minimum charge
# that needs to be present in the car battery to have enough "fuel" to run the
# next trip. The remaining battery volume could be used to store electricity 
# (and use it later). From the required charge for the next trip and the 
# charging rate, we calculate when the car has to start charging.
#
# The availability is expressed as a percentage of the battery volume.
#==============================================================================

close()

# departure time, arrival time, distance travelled (km) from Verzijlbergh (2013)
work_data = [[ 7.38, 17.58,   4.3],
             [ 9.06, 18.33,  50.8],
             [ 9.07, 17.17,  31.0],
             [ 9.09, 19.24,  91.8],
             [ 9.11, 18.59,  77.0],
             [ 9.13, 18.25,  40.1],
             [ 9.16, 16.50,  24.8],
             [ 9.16, 18.45,  58.8],
             [ 9.26, 18.34,  35.2],
             [ 9.26, 19.25, 109.2],
             [ 9.40, 19.22,  65.9]]
             
# departure time, arrival time, distance travelled (km) from Verzijlbergh (2013)
other_data = [[ 8.38, 22.17,  4.5],
              [ 8.41, 14.26,  7.8],
              [ 9.08, 16.01, 19.5],
              [ 9.13, 15.27, 10.9],
              [ 9.31, 15.21, 14.5],
              [10.11, 13.12,  3.1],
              [10.11, 18.46, 45.2],
              [10.27, 15.20,  5.7],
              [11.07, 18.58, 21.7],
              [11.21, 18.54, 16.8],
              [11.31, 19.11, 28.2],
              [13.21, 18.26, 11.8],
              [15.04, 19.22,  3.2],
              [15.09, 19.48,  7.9]]
              
# charging power in kW
charging_powers = [ 3.7,
                    5.0,
                   10.0]
                   
# battery volume in kWh
volume = 25.0

# efficiency of the EV in km / kWh
efficiency = 5.0

# total weekdays in a year
annual_work_days = 260.
# average number of days worked annualy in the Netherlands
annual_days_worked = 212.

# year for which the profiles are generated
year = 2013

def randomize_trip_data(trip_data):

    departure_time = trip_data[0]   
    arrival_time = trip_data[1]
    distance = trip_data[2]
    
    # calculate departure and arrival times in quarters
    departure_time = floor(departure_time) * 4 + remainder(departure_time, 1)/0.15
    arrival_time = floor(arrival_time) * 4 + remainder(arrival_time, 1)/0.15

    # randomize departure and arrival times by adding a random number in the
    # interval [-2,2] quarters
    departure_time += random.uniform(-2,2)
    arrival_time += random.uniform(-2,2)
    
    # round the departure time to the closest lower quarter
    departure_time = int(floor(departure_time))
   
    # round the arrival time to the closest higher quarter
    arrival_time = int(ceil(arrival_time))
       
    return [departure_time, arrival_time, distance]
    
    
def work_day():

    return randomize_trip_data(work_data[driver])


def weekend_day():
    
    return randomize_trip_data(random.choice(other_data))


def annual_charge_times():
    # generate a list of trip data, one for every day of the year    
    
    charge_times = [] 

    start_date = datetime.date.toordinal(datetime.date(year,1,1))
    end_date = datetime.date.toordinal(datetime.date(year+1,1,1))
    
    for i in range(0, end_date - start_date):
    
        weekday = datetime.date.weekday(datetime.date.fromordinal(i + start_date))
        
        time_shift = [i*96, i* 96, 0]
        
        if weekday <= 4:
            
            # Taking into account (public) holidays and sick days
            p_day_worked = annual_days_worked / annual_work_days          
          
            if numpy.random.choice((0,1),p=[1 - p_day_worked, p_day_worked]) == 1:
            
                charge_times.append(map(sum,zip(work_day(), time_shift)))
            
            else:
                
                charge_times.append(map(sum,zip([0, 0, 0], time_shift)))
        
        else:
            
            charge_times.append(map(sum,zip(weekend_day(), time_shift)))

    return charge_times


def generate_availability_profile(trips_data, charging_power):
    # generate availability profiles from a list of trip data
    
    availability_profile = zeros(len(trips_data) * 96)
        
    for i in range(0,len(trips_data)):
        
        trip_data = trips_data[i]
          
        distance = trip_data[2]
        required_charge = distance / efficiency 
        
        # make sure that we never charge the EV shorter than required
        charging_time = int(ceil(required_charge / charging_power * 4.0))
              
        quarters_charged = 0.
                             
        for j in range(trip_data[0] - charging_time, trip_data[0] + 1):
            
            if charging_time != 0:            
                availability_profile[j] = quarters_charged * charging_power / 4.0 / volume
                
                quarters_charged += 1.
                
        for k in range(trip_data[0] + 1, trip_data[1]):
            
            availability_profile[k] = -required_charge / volume 

    return availability_profile    
    
    
# main loop    

for i in range(0, len(work_data)):

    for j in range(0, len(charging_powers)): 
    
        driver = i
        charging_power = charging_powers[j]
        
        availability_profile = generate_availability_profile(annual_charge_times(), charging_power)
        
        filename = 'ev_availability_profile_' + str(driver+1) + '_' + str(charging_power) + '_kW.csv'
        #savetxt(filename, availability_profile, fmt='%.3f', delimiter=',')
        
        figure(figsize=[15,10])
        
        print max(availability_profile)
        
        for k in range(0, 52):
            
            plot(availability_profile[k * 7 * 96 : (k +  1) * 7 * 96])
            xlabel("time step [15 minutes]")
            ylabel("availability [-]")
            title("driver: " + str(driver) + ", charging power: " + str(charging_power))
            ylim(-1,1)
            
        show()