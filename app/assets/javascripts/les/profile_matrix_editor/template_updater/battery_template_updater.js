var BatteryTemplateUpdater = (function () {
    'use strict';

    var defaultPercentage = 20.0,
        batteryToggles = ".editable.profile",
        batteries = [
            "congestion_battery",
            "households_flexibility_p2p_electricity"
        ],
        sliderSettings = { tooltip: 'hide' };

    function setSlideStopValue() {
        var sliderValue = $(this).val();

        $(this).parents(".editable").find(".tick.value").text(sliderValue + "%");
    }

    BatteryTemplateUpdater.prototype = {
        update: function () {
            var isBattery           = (batteries.indexOf(this.data.type) > -1),
                isCongestionBattery = ("congestion_battery" === this.data.type),
                batterySlider       = this.template.find(".battery-slider"),
                sliderInput         = batterySlider.find("input"),
                reserveValue;

            if (isBattery) {
                this.template.find(batteryToggles).addClass("hidden");
            }

            batterySlider.toggleClass("hidden", !isCongestionBattery);

            if (isCongestionBattery) {
                if (this.data.hasOwnProperty('congestionReservePercentage')) {
                    reserveValue = parseFloat(
                        this.data.congestionReservePercentage
                    );
                } else {
                    reserveValue = defaultPercentage;
                }

                sliderInput.slider(sliderSettings)
                    .slider('setValue', reserveValue)
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
