var Calculations = (function () {
    'use strict';

    return {
        calculateInputCapacity: function () {
            var capacity               = this.capacity || 0,
                performanceCoefficient = this.performanceCoefficient || 1;

            return capacity / performanceCoefficient;
        }
    };
}());
