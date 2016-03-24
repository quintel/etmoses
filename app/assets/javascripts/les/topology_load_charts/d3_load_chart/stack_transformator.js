var StackTransformator = (function () {
    'use strict';

    var stack = d3.layout.stack()
        .values(function(d) { return d.values; });

    StackTransformator.prototype = {
        transform: function () {
            var size = this.data[0].values.length;

            while(size--) {
                var posOffset = 0,
                    negOffset = 0;

                this.data.forEach(function(d) {
                    d = d.values[size];

                    if (d.y < 0) {
                        d.offset = negOffset;
                        negOffset += d.y;
                    }
                    else {
                        d.offset = posOffset;
                        posOffset += d.y;
                    }
                });
            }

            return stack(this.data);
        }
    };

    function StackTransformator(data) {
        this.data = data;
    }

    return StackTransformator;
}());
