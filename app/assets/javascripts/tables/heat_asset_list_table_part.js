/*globals EditableTable*/

var HeatAssetListTablePart = (function () {
    'use strict';

    var editableTable;

    /* Callback for profile selector
     * Whenever somebody select's a different heat asset the data from that
     * select option will be parsed over the table row and the values set
     * in their respectable inputs and select boxes.
     */
    function updateRows(technology) {
        var technology = $(this.target).find("select.key"),
            techData   = $(technology)
                            .find("option[value=" + technology.val() + "]")
                            .data();

        for (var key in techData) {
            $(this.target)
                .find(".editable." + key.underscorize())
                .find("input, select")
                .val(techData[key]);
        }
    }

    HeatAssetListTablePart.prototype = {
        append: function () {
            this.setProfiles();
        },

        setProfiles: function () {
            $(this.editableTable.selector).find("tr:not(.blank)").each(function() {
                new ProfileSelectBox(this).add(updateRows);
            });
        }
    };

    function HeatAssetListTablePart(selector) {
        this.editableTable = new EditableTable(selector);
    }

    return HeatAssetListTablePart;
}());
