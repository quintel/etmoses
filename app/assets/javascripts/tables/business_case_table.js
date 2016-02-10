/*globals Poller,StrategyHelper*/

var BusinessCaseTable = (function () {
    'use strict';

    function finish() {
        $.ajax({ type: "POST", url: this.urls.finishUrl });
    }

    BusinessCaseTable.prototype = {
        create: function () {
            if (this.table.length < 1) { return false; }

            new Poller({
                url: this.urls.url,
                data: StrategyHelper.getStrategies()
            }).poll().done(finish.bind(this));
        }
    };

    function BusinessCaseTable(table) {
        this.table = table;
        this.urls  = table.data();
    }

    return BusinessCaseTable;
}());
