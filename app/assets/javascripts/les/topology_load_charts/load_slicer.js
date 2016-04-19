var LoadSlicer = (function () {
    'use strict';

    return {
        slice: function(loads, week) {
            var chunkSize;

            if (week && week !== 0) {
                chunkSize = Math.floor(loads.length / 52);

                loads = loads.slice((week - 1) * chunkSize, week * chunkSize);
            }

            return loads;
       }
    }
}());
