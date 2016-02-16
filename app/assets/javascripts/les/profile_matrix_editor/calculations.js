var Calculations = (function () {
    return {
        calculateInputCapacity: function() {
            return (Math.round(
                (this.capacity / (this.performanceCoefficient || 1)) * 10000)
                / 10000);
        }
    };
}());
