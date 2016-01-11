var BatteryTemplateUpdater = (function () {
    'use strict';

    var defaultPercentage = 20.0,
        batteryToggles = ".editable.profile",
        batteries = [
            "congestion_battery",
            "households_flexibility_p2p_electricity"
        ],
        sliderSettings = {
            tooltip: 'hide',
            formatter: function (value) {
                return value + "%";
            }
        };

    function setSlideStopValue() {
        var sliderValue = $(this).val();

        $(this).parents(".editable").find(".tick.value").text(sliderValue + "%");
    }

    BatteryTemplateUpdater.prototype = {
        update: function () {
            var isBattery           = (batteries.indexOf(this.data.type) > -1),
                isCongestionBattery = ("congestion_battery" === this.data.type),
                batterySlider       = this.template.find(".battery-slider"),
                sliderInput         = batterySlider.find("input");

            this.template.find(batteryToggles).toggleClass("hidden", isBattery);

            batterySlider.toggleClass("hidden", !isCongestionBattery);

            if (isCongestionBattery) {
                sliderInput.slider(sliderSettings)
                    .slider('setValue', defaultPercentage)
                    .on('slide', setSlideStopValue)
                    .trigger('slide');


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
