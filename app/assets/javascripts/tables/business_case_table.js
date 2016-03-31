/*globals Poller,StrategyHelper*/

var BusinessCaseTable = (function () {
    'use strict';

    function finish() {
        $.ajax({ type: "POST", url: this.urls.finishUrl });

        $("#business_case_table .loading-spinner").removeClass("on");
        $("select#compare").prop('disabled', false);
    }

    function showLoadingSpinner() {
        $("#business_case_table .loading-spinner").addClass("on");
        $("select#compare").prop('disabled', true);
    }

    function getOptions() {
        return {
            url: this.urls.url,
            data: {
                strategies: StrategyHelper.getStrategies()
            },
            first_data: {
                clear: true
            }
        };
    }

    BusinessCaseTable.prototype = {
        reload: function () {
            if (this.table.length < 1 || window.currentTree.d3Chart.lesOptions.resolution === "high") {
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
        this.urls  = this.table.data();
    }

    return BusinessCaseTable;
}());
