var ChartSettings = (function () {
    'use strict';

    return {
        data: {},

        initialize: function () {
            var chartSettings;

            $(".hidden .chart-settings div").each(function (i, el) {
                chartSettings = $(el).data();
                chartSettings.visible = (chartSettings.type !== 'capacity');

                this.data[chartSettings.type] = chartSettings;
            }.bind(this));
        },

        forChart: function (chartKey) {
            if (!this.data.hasOwnProperty(chartKey)) {
                throw new Error('No such chart setting: ' + chartKey);
            }

            return this.data[chartKey];
        }
    };
}());

$(document).on('page:change', function () {
    'use strict';

    ChartSettings.initialize();
});
