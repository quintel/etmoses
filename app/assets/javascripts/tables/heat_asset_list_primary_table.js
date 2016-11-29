/*globals EditableTable*/

var HeatAssetListPrimaryTable = (function () {
    'use strict';

    function reloadHeatAssets(e) {
        var reloadButton = $(e.target).data();

        if (confirm(reloadButton.confirmation)) {
            $.ajax({ type: 'POST', url: reloadButton.url });
        }
    }

    HeatAssetListPrimaryTable.prototype = $.extend({}, EditableTable.prototype, {
        afterAppendCallback: function () {
            $(".reload-heat-asset-list")
                .off('click')
                .on('click', reloadHeatAssets.bind(this));
        }
    });

    function HeatAssetListPrimaryTable(selector) {
        EditableTable.call(this, selector);
    }

    return HeatAssetListPrimaryTable;
}());
