/*globals I18n,LoadSlicer*/

var HeatTransformer = (function () {
    'use strict';

    function fetchChart(data, totals) {
        var chart,
            subChart,
            totals = (totals || []);

        for (chart in data) {
            if (data.hasOwnProperty(chart)) {
                subChart = data[chart];

                if (subChart.length && subChart.length > 0) {
                    totals.push({
                        type: chart,
                        name: I18n.t("charts." + chart),
                        area: true,
                        values: { total: LoadSlicer.slice(subChart, 0) }
                    });
                } else {
                    fetchChart(subChart, totals);
                }
            }
        }

        return totals;
    }

    function withDeficit(data) {
        var deficit = [],
            length  = data.length,
            newData,
            techIndex;

        if (!length) {
            return data;
        }

        deficit = data[0].values.total.map(function (val, index) {
            var net = 0;

            for (techIndex = 0; techIndex < length; techIndex++) {
                net = net + data[techIndex].values.total[index];
            }

            return (net < 0 ? 0.0 : -net);
        });

        if (!deficit.some(function (v) { return v < 0 })) {
            // No deficit; don't show the series.
            return data;
        }

        newData = data.slice(0);

        newData.push({
            area: true,
            name: I18n.t('charts.deficit'),
            type: 'deficit',
            values: { total: deficit }
        });

        return newData;
    }

    return {
        transform: function (data) {
            return withDeficit(fetchChart(data));
        }
    };
}());
