/*globals EditableTable*/

var HeatAssetListTablePart = (function () {
    'use strict';

    var editableTable;

    HeatAssetListTablePart.prototype = {
        append: function () {
            setProfiles.call(this);

            this.editableTable.append(this.updateTable);
        },

        setProfiles: function() {
            $(this.editableTable.selector).find("tr:not(.blank)").each(function() {
                new ProfileSelectBox(this).add();
            });
        }
    };

    function HeatAssetListTablePart(selector) {
        this.editableTable = new EditableTable(selector);
    }

    return HeatAssetListTablePart;
}());


