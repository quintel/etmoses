/*globals confirm*/

(function () {
    'use strict';

    var calculateConcurrency, technology_distribution, topology_id;

    calculateConcurrency = function () {
        $.ajax({
            url: '/testing_grounds/calculate_concurrency',
            type: "POST",
            dataType: "script",
            data: {
                technology_distribution: technology_distribution(),
                topology_id: topology_id()
            }
        });
    };

    topology_id = function () {
        return $("#testing_ground_topology_id").val();
    };

    technology_distribution = function () {
        var concurrency, tech, tech_distribution, tech_distribution_json, i,
            isMaxConcurrency;

        tech_distribution = JSON.parse($("textarea#technology_distribution").text());

        for (i = 0; i < tech_distribution.length; i += 1) {
            tech = tech_distribution[i];
            isMaxConcurrency = $(".check_box input[name='" + tech.type + "']").prop('checked');
            tech.concurrency = (isMaxConcurrency ? 'max' : 'min');
        }
        tech_distribution_json = JSON.stringify(tech_distribution);

        $("textarea#technology_distribution").text(tech_distribution_json);

        return tech_distribution_json;
    };

    $(document).on("page:change", function () {
        if ($("#new_testing_ground, .edit_testing_ground").length > 0) {
            $(".toggle-concurrency").click(function (event) {
                event.preventDefault();

                if ($(this).hasClass("edit")) {
                    if (confirm("Are you sure? Changing concurrency might cause unwanted changes")) {
                        calculateConcurrency();
                    }
                } else {
                    calculateConcurrency();
                }
            });

            $(".toggle-whitelist").click(function (event) {
                event.preventDefault();
                $(this).toggleClass("all-max");
                $(".check_box input").prop("checked", !$(this).hasClass("all-max")).change();
            });
        }
    });
}).call(this);
