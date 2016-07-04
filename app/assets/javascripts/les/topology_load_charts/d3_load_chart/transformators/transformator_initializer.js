var TransformatorInitializer = (function() {
    'use strict';

    return {
        initialize: function (settings) {
            if (settings.curve_type === 'heat') {
                return HeatTransformator;
            } else {
                return StaticTransformator;
            }
        }
    }
}());
