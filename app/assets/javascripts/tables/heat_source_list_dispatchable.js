/*globals EditableTable*/

var HeatSourceListDispatchable = (function () {
    'use strict';

    function updateSort() {
        $(this.selector).find("tbody tr").each(function (i) {
            $(this).find("td input[name=priority]").val(i);
        });

        this.changeListener();
    }

    HeatSourceListDispatchable.prototype = $.extend({}, EditableTable.prototype, {
        afterAppendCallback: function () {
            $(this.selector).find("tbody").sortable({
                axis: "y",
                update: updateSort.bind(this)
            });
        }
    });

    function HeatSourceListDispatchable(selector) {
        EditableTable.call(this, selector);
    }

    return HeatSourceListDispatchable;
}());

