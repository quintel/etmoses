var StaticTransformator = (function () {
    'use strict';

    return {
        transform: function (data, week) {
            var totals = [];

            data.values.forEach(function(item) {
                totals.push({
                    type: item.type,
                    name: item.name,
                    area: true,
                    values: { total: LoadSlicer.slice(item.load, week) }
                });
            });

            return totals;
        }
    }
}());
