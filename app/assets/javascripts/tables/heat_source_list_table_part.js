/*globals EditableTable*/

var HeatSourceListTablePart = (function () {
    'use strict';

    var editableTable;

    HeatSourceListTablePart.prototype = {
        append: function () {
            setProfiles.call(this);

            this.editableTable.append();
        },

        setProfiles: function() {
            $(this.editableTable.selector).find("tr:not(.blank)").each(function() {
                new ProfileSelectBox(this).add();
            });
        }
    };

    function HeatSourceListTablePart(selector) {
        this.editableTable = new EditableTable(selector);
    }

    return HeatSourceListTablePart;
}());

