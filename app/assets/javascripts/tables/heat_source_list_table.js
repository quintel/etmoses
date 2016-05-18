/*globals EditableTable*/

var HeatSourceListTable = (function () {
    'use strict';

    var editableTable;

    HeatSourceListTable.prototype = {
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

    function HeatSourceListTable(selector) {
        this.editableTable = new EditableTable(selector);
    }

    return HeatSourceListTable;
}());

