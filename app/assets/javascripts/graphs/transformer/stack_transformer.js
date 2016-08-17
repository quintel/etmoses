var StackTransformer = (function () {
    'use strict';

    function spikeness(data) {
        var values = data.values.map(function (p) { return p.y } );

        return Math.abs((d3.max(values) - d3.min(values)) / d3.sum(values));
    }

    return {
        transform: function (data) {
            if (data.length <= 0) {
                throw "data must be of length > 0";
            }

            var size,
                posOffset,
                negOffset;

            data.sort(function (a,b) {
                return spikeness(a) > spikeness(b);
            });

            size = data[0].values.length;

            while (size--) {
                posOffset = 0;
                negOffset = 0;

                data.forEach(function (d) {
                    d = d.values[size];

                    if (d.y < 0) {
                        d.offset = negOffset;
                        negOffset += d.y;
                    } else {
                        d.offset = posOffset;
                        posOffset += d.y;
                    }
                });
            }

            return d3.layout.stack()
                .values(function (d) { return d.values; })
                .call(null, data);
        }
    };
}());
