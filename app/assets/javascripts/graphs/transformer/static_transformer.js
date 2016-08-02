/*globals LoadSlicer*/

var StaticTransformer = (function () {
    'use strict';

    return {
        transform: function (data, week) {
            var totals = [];

            data.type = data.key;
            data.values.forEach(function (item) {
                totals.push({
                    type: item.type,
                    name: item.name,
                    area: (data.key !== 'gas'),
                    values: { total: LoadSlicer.slice(item.load, week) }
                });
            });

            return totals;
        }
    };
}());