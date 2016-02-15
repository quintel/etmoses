var Calculations = (function () {
    return {
        calculateInputCapacity: function() {
            return (Math.round(
                (this.capacity / this.performanceCoefficient) * 10000)
                / 10000);
        }
    };
}());
