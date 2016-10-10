/*globals ChartSettings,LoadSlicer*/

var StaticTransformer = (function () {
    'use strict';

    return {
        transform: function (data, week) {
            var settings,
                totals = [];

            data.type = data.key;
            data.values.forEach(function (item) {
                settings = ChartSettings.forChart(item.type);

                totals.push({
                    type: item.type,
                    name: item.name,
                    area: settings.area,
                    areaColor: settings.areaColor,
                    values: { total: LoadSlicer.slice(item.load, week) }
                });
            });

            return totals;
        }
    };
}());
