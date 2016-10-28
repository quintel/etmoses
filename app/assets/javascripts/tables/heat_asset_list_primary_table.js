/*globals EditableTable*/

var HeatAssetListPrimaryTable = (function () {
    'use strict';

    HeatAssetListPrimaryTable.prototype = $.extend({}, EditableTable.prototype);

    function HeatAssetListPrimaryTable(selector) {
        EditableTable.call(this, selector);
    }

    return HeatAssetListPrimaryTable;
}());
