/*globals HeatTransformer,StaticTransformer*/

var TransformerInitializer = (function () {
    'use strict';

    return {
        initialize: function (settings) {
            var transformers = {
                heat: HeatTransformer
            };

            return transformers[settings.curve_type] || StaticTransformer;
        }
    };
}());
