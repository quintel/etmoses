/*globals EditableTable*/

var HeatSourceListDispatchable = (function () {
    'use strict';

    function updateSort() {
        $(this.editableTable.selector).find("tbody tr").each(function (i) {
            $(this).find("td input[name=priority]").val(i);
        });

        this.editableTable.changeListener();
    }

    HeatSourceListDispatchable.prototype = $.extend({}, EditableTable.prototype, {
        afterAppendCallback: function () {
            $(this.editableTable.selector).find("tbody").sortable({
                axis: "y",
                update: updateSort.bind(this)
            });
        }
    });

    function HeatSourceListDispatchable(selector) {
        this.editableTable = new EditableTable(selector);
    }

    return HeatSourceListDispatchable;
}());

