var TemplateSettings = (function () {
    'use strict';

    /*
     * ignoredTechs
     *    Technologies that don't exist in et-engine
     *
     * etmKeys:
     *    Attributes that are to be used from et-engine
     *    The attributes are camelcased due to HTML5 DOM API
     */
    return {
        ignoredTechs: [
            undefined,
            '',
            'base_load',
            'base_load_buildings',
            'base_load_edsn',
            'buffer_space_heating',
            'buffer_water_heating',
            'congestion_battery',
            'households_space_heater_hybrid_heatpump_air_water_electricity_electricity',
            'households_space_heater_hybrid_heatpump_air_water_electricity_gas',
            'households_water_heater_hybrid_heatpump_air_water_electricity_electricity',
            'households_water_heater_hybrid_heatpump_air_water_electricity_gas',
            'generic'
        ],
        etmKeys: [
            'technicalLifetime', 'initialInvestment', 'fullLoadHours',
            'omCostsPerYear', 'omCostsPerFullLoadHour', 'omCostsForCcsPerFullLoadHour'
        ]
    };
}());
