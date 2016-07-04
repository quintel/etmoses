var StackTransformator = (function () {
    'use strict';

    var stack = d3.layout.stack()
        .values(function(d) { return d.values; });

    return {
        transform: function (data) {
            if (data.length > 0) {
                var size = data[0].values.length;

                while(size--) {
                    var posOffset = 0,
                        negOffset = 0;

                    data.forEach(function(d) {
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
            }

            data.sort(function (a,b) {
                return a.key > b.key;
            });

            return stack(data);
        }
    };
}());
