/*globals EditableTable*/

var HeatAssetListTablePart = (function () {
    'use strict';

    var editableTable;

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

            this.editableTable.append(this.updateTable.bind(this));
        },

        updateTable: function () {
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
