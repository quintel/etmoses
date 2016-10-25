/*globals EditableTable*/

var HeatAssetListPrimaryTable = (function () {
    'use strict';

    HeatAssetListPrimaryTable.prototype = $.extend({}, EditableTable.prototype, {
        rowAddedListener: function () {
            this.setProfiles();
        }
    });

    function HeatAssetListPrimaryTable(selector) {
        EditableTable.call(this, selector);
    }

    return HeatAssetListPrimaryTable;
}());
