# -*- coding: utf-8 -*-
"""
Created on Wed Jul 15 10:22:40 2015

@author: chael.kruip@quintel.com
"""

import numpy as np

# From https://www.qurrent.nl/energietarieven

high_tariff = 0.044
low_tariff = 0.032

high_range = np.arange(28, 92) # 15 minute steps between 7:00 and 23:00

steps_per_year = 365 * 24 * 4

out_file = open("../output_data/day_and_night_tariff_2013.csv",'w')
for time_step in range(steps_per_year):
    
    reduced_time = time_step % 96
    if reduced_time in high_range:
        
        out_file.write(str(high_tariff)+"\n")
        
    else:

        out_file.write(str(low_tariff)+"\n")
        
out_file.close()