import numpy as np

class house:
    
    def __init__(self, floor_area, window_area, thermostate_temperature):
        
        self.thermostate_temperature = thermostate_temperature
        self.window_area = window_area
        self.floor_area = floor_area
        self.roof_area = floor_area
        self.wall_area = 4 * 5 * np.sqrt(self.floor_area) - self.window_area # 4 walls of 5 meters high
        self.outside_area = self.floor_area + self.roof_area + self.wall_area + self.window_area
        self.volume = 5 * floor_area # Houses are 5 meters high
        self.heat_demand = 0.0
        self.u_roof = 0.9
        self.u_floor= 0.7
        self.u_wall = 0.7
        self.u_window = 2.9
        self.kWh_leaked_per_hour_per_Kelvin =   (self.u_roof * self.roof_area +\
                                                self.u_floor * self.floor_area +\
                                                self.u_wall * self.wall_area +\
                                                self.u_window * self.window_area) / 1000.0 # from W to kWh/h
        self.heat_loss_parameter = self.kWh_leaked_per_hour_per_Kelvin * 1000.0 / self.floor_area
        
    def print_info(self):
        
        print "House properties:"
        print "thermostate_temperature ", self.thermostate_temperature
        print "wall_area ", self.wall_area
        print "outside_area ", self.outside_area
        print "volume ", self.volume
        print "heat_demand ", self.heat_demand
        print "kWh_leaked_per_hour_per_Kelvin ", self.kWh_leaked_per_hour_per_Kelvin
        print "heat_loss_parameter ", self.heat_loss_parameter, " (1.1 is 'sustainable' pag. 295 SEWTHA)"
        print ""
        
    def exchange_heat_with_outside(self, outside_temperature, irradiance_per_m2):
        
        temperature_difference = self.thermostate_temperature - outside_temperature

        # This works also if it is warmer outside than inside
        self.heat_demand = self.kWh_leaked_per_hour_per_Kelvin * temperature_difference - irradiance_per_m2 * self.window_area
       
    def get_heat_demand(self):
        
        return self.heat_demand


### Class for a storage tank
class tank:
    '''Tank for storage of hot water'''
    
    def __init__(self, content, min_content_in_kWh, max_content_in_kWh, leakage_fraction_per_hour):
        self.content = content
        self.max_content = max_content_in_kWh
        self.min_content = min_content_in_kWh
        self.leakage_fraction_per_hour = leakage_fraction_per_hour

    def print_info(self):
        
        print "Tank properties:"
        print "Min energy content of tank:", self.min_content, " kWh"
        print "Max energy content of tank:", self.max_content, " kWh"
        print ""


    def extract(self, amount_in_kWh):
        if self.content > amount_in_kWh:
            self.content -= amount_in_kWh
            return amount_in_kWh
        else:
            output = self.content
            self.content = 0.0
            return output

    def request_storage(self):
        
        if self.content < self.min_content:
            return True
        else:
            return False
            
    def storage_capacity(self):
        return self.max_content - self.content

    def content(self):
        return self.content

    def store(self, amount):
        self.content += amount
        
    def leak(self):
        self.content *= (1.0 - self.leakage_fraction_per_hour)