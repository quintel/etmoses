/*globals EditableTable*/

var HeatSourceListMustRun = (function () {
    'use strict';

    HeatSourceListMustRun.prototype = $.extend({}, EditableTable.prototype, {
        rowAddedListener: function () {
            this.setProfiles();
        }
    });

    function HeatSourceListMustRun(selector) {
        EditableTable.call(this, selector);

        this.setProfiles();
    }

    return HeatSourceListMustRun;
}());
