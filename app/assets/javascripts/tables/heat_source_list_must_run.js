/*globals EditableTable*/

var HeatSourceListMustRun = (function () {
    'use strict';

    function setProfiles() {
        $(this.editableTable.selector).find("tr:not(.blank)").each(function() {
            new ProfileSelectBox(this).add();
        });
    }

    HeatSourceListMustRun.prototype = {
        afterAppendCallback: setProfiles,
        mergeCallback: setProfiles
    };

    function HeatSourceListMustRun(selector) {
        this.editableTable = new EditableTable(selector);
    }

    return HeatSourceListMustRun;
}());

