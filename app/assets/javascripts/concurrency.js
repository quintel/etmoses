/*globals confirm*/

var ConcurrencyToggler = (function () {
    'use strict';

    function concurrencyForType(tech) {
        return $(".check_box input[name='" + tech.type + "']").prop('checked');
    }

    function techList() {
        var distribution = $("textarea#technology_distribution").text();

        return JSON.parse(distribution).map(function (tech) {
            tech.concurrency = (concurrencyForType(tech) ? 'max' : 'min');
            return tech;
        });
    }

    function concurrencyRequestFinished() {
        this.techList = techList();
    }

    function sendConcurrencyRequest(currentTechList) {
        $.ajax({
            url: '/testing_grounds/calculate_concurrency',
            type: "POST",
            success: concurrencyRequestFinished.bind(this),
            dataType: "script",
            data: {
                technology_distribution: currentTechList,
                topology_id: $("#testing_ground_topology_id").val()
            }
        });
    }

    function isEqualDistribution(currentTechList) {
        var isEqual = true;

        if (this.techList.length !== currentTechList.length) {
            isEqual = false;
        } else {
            this.techList.forEach(function (tech, i) {
                if (currentTechList[i].concurrency !== tech.concurrency) {
                    isEqual = false;
                }
            });
        }

        return isEqual;
    }

    ConcurrencyToggler.prototype = {
        calculate: function () {
            var currentTechList = techList();

            if (!(isEqualDistribution.call(this, currentTechList))) {
                $(".toggle-concurrency").prop("disabled", true);
                $("textarea#technology_distribution").text(JSON.stringify(currentTechList));

                sendConcurrencyRequest.call(this, JSON.stringify(currentTechList));
            }
        }
    };

    function ConcurrencyToggler() {
        this.techList = techList();
    }

    return ConcurrencyToggler;
}());


$(document).on("page:change", function () {
    'use strict';

    if ($("#new_testing_ground, .edit_testing_ground").length > 0) {
        var concurrencyToggler = new ConcurrencyToggler();

        $(".toggle-concurrency").click(function (event) {
            event.preventDefault();

            if ($(this).hasClass("edit")) {
                if (confirm("Are you sure? Changing concurrency might cause unwanted changes")) {
                    concurrencyToggler.calculate();
                }
            } else {
                concurrencyToggler.calculate();
            }
        });

        $(".toggle-whitelist").click(function (event) {
            event.preventDefault();

            $(this).toggleClass("all-max");
            $(".check_box input").prop("checked", !$(this).hasClass("all-max")).change();
        });
    }
});
