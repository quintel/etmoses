/*globals EditableTable*/

var HeatSourceListMustRun = (function () {
    'use strict';

    HeatSourceListMustRun.prototype = $.extend({}, EditableTable.prototype, {
        afterAppendCallback: function () {
            this.setProfiles();
        },

        mergeCallback: function () {
            this.setProfiles();
        }
    });

    function HeatSourceListMustRun(selector) {
        EditableTable.call(this, selector);
    }

    return HeatSourceListMustRun;
}());
