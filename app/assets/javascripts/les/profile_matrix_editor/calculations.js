var Calculations = (function () {
    return {
        calculateInputCapacity: function() {
            var capacity               = this.capacity || 0,
                performanceCoefficient = this.performanceCoefficient || 1;

            return (Math.round(capacity / performanceCoefficient * 10000)
                / 10000);
        }
    };
}());
