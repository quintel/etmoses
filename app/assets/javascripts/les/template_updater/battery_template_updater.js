var BatteryTemplateUpdater = (function () {
    'use strict';

    var defaultPercentage = 20.0,
        batteryToggles = ".editable.profile",
        batteries = [
            "neighbourhood_battery",
            "households_flexibility_p2p_electricity"
        ],
        sliderSettings = {
            tooltip: 'show',
            formatter: function (value) {
                return value + "%";
            }
        };

    BatteryTemplateUpdater.prototype = {
        update: function () {
            var isBattery              = (batteries.indexOf(this.data.type) > -1),
                isNeighbourhoodBattery = ("neighbourhood_battery" === this.data.type),
                batterySlider          = this.template.find(".battery-slider"),
                sliderInput            = batterySlider.find("input");

            this.template.find(batteryToggles).toggleClass("hidden", isBattery);

            batterySlider.toggleClass("hidden", !isNeighbourhoodBattery);

            if (isNeighbourhoodBattery) {
                sliderInput.slider(sliderSettings).slider('setValue', defaultPercentage);
                this.template.set(sliderInput.data('type'), defaultPercentage);
            }

            return this.template;
        }
    };

    function BatteryTemplateUpdater(context) {
        this.data     = context.data;
        this.template = context.template;
    }

    return BatteryTemplateUpdater;
}());
