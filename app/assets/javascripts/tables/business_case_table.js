/*globals Poller,StrategyHelper*/
var BusinessCaseTable = (function () {
    'use strict';

    function finish() {
        $.ajax({ type: "POST", url: this.data.finishUrl });

        $("#business_case_table .loading-spinner").removeClass("on");
        $("select#compare").prop('disabled', false);
    }

    function showLoadingSpinner() {
        $("#business_case_table .loading-spinner").addClass("on");
        $("select#compare").prop('disabled', true);
    }

    function getOptions() {
        return {
            url: this.data.url,
            data: {
                strategies: StrategyHelper.getStrategies()
            },
            first_data: {
                clear: this.data.clear
            }
        };
    }

    BusinessCaseTable.prototype = {
        reload: function () {
            if (this.table.length < 1) {
                return false;
            }

            $(".no-business-case-message").addClass("hidden");
            this.table.find(".placeholder").removeClass("hidden");

            new Poller(getOptions.call(this)).poll()
                .progress(showLoadingSpinner)
                .done(finish.bind(this));
        },

        setNoCaseMessage: function () {
            $(".no-business-case-message").removeClass("hidden");
            this.table.find(".placeholder").addClass("hidden");
        }
    };

    function BusinessCaseTable(table) {
        this.table = $(table);
        this.data  = this.table.data();
    }

    return BusinessCaseTable;
}());
