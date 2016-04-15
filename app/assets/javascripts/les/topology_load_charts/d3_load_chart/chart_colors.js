var ChartColors = (function () {
    'use strict';

    var result = {},
        colorScale = [
            "#8c5e5e", "#eaee4e", "#64edde", "#ee841a", "#ed9bee",
            "#7bc2eb", "#819a47", "#ee526a", "#a7ed8e", "#62988e",
            "#c59e04", "#a76426", "#a182b8", "#d25e92", "#55e4e8",
            "#6cbe8a", "#b8524c", "#aec944", "#827041", "#e75c39",
            "#748eaa", "#edd417", "#977e21", "#aab0ee", "#c87d02",
            "#747669", "#56c8b8", "#80e7b0", "#6e8c60", "#87c66a",
            "#a46384", "#cc7abe", "#61b4ca", "#ee79ca", "#cdee6d",
            "#ee5a90", "#945d3e", "#88738b", "#cbc221", "#9ea02b",
            "#cd9de4", "#cd6720", "#ce516c", "#bb5732", "#a95662",
            "#8b9cd3", "#5aeeee", "#da4e4d", "#ee6e2e", "#64a381"
        ],
        technologies = [
            "base_load",
            "base_load_buildings",
            "base_load_edsn",
            "buffer_space_heating",
            "buffer_water_heating",
            "congestion_battery",
            "energy_flexibility_p2g_electricity",
            "generic",
            "households_flexibility_p2h_electricity",
            "households_flexibility_p2p_electricity",
            "households_solar_pv_solar_radiation",
            "households_space_heater_combined_network_gas",
            "households_space_heater_heatpump_air_water_electricity",
            "households_space_heater_heatpump_ground_water_electricity",
            "households_space_heater_hybrid_heatpump_air_water_electricity",
            "households_space_heater_hybrid_heatpump_air_water_electricity_electricity",
            "households_space_heater_hybrid_heatpump_air_water_electricity_gas",
            "households_space_heater_micro_chp_network_gas",
            "households_space_heater_network_gas",
            "households_water_heater_combined_network_gas",
            "households_water_heater_fuel_cell_chp_network_gas",
            "households_water_heater_heatpump_air_water_electricity",
            "households_water_heater_heatpump_ground_water_electricity",
            "households_water_heater_hybrid_heatpump_air_water_electricity",
            "households_water_heater_hybrid_heatpump_air_water_electricity_electricity",
            "households_water_heater_hybrid_heatpump_air_water_electricity_gas",
            "households_water_heater_micro_chp_network_gas",
            "households_water_heater_network_gas",
            "transport_car_using_electricity"
        ];

    technologies.forEach(function (tech, index) {
        result[tech] = colorScale[index];
    })

    return result;
}());
