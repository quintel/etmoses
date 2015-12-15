/*global StrategyHelper,LoadChartHelper,Poller,TreeFetcher*/
var StrategyToggler = (function () {
    'use strict';

    var loadChart, applyStrategyButton, businessCaseTable, savedStrategies, changedStrategy,
        sliderSettings = {
            focus: true,
            formatter: function (value) {
                return value + "%";
            }
        },
        multiSelectSettings = {
            buttonText: function (options) {
                var text = 'Customise technology behaviour';

                if (options.length) {
                    text = text + ' (' + options.length + ' selected)';
                }

                return text;
            },
            dropRight: true
        };

    function showSlider() {
        var sliderWrapper = $(this).parents('a').find(".slider-wrapper");

        sliderWrapper.toggleClass("hidden", !$(this).is(":checked"));
    }

    function buildMultiSelect() {
        var multiSelect = $("select.multi-select");
        multiSelect.multiselect(multiSelectSettings);

        return multiSelect;
    }

    function getSelectedItems() {
        var selected = [],
            strategy;

        for (strategy in savedStrategies) {
            if (savedStrategies[strategy]) {
                selected.push(strategy);
            }
        }
        return selected;
    }

    function updateLoadChart(strategyData) {
        this.toggleLoading();

        loadChart.applyStrategies(strategyData);
    }

    function pollTree() {
        new TreeFetcher(this.urls).fetch({
            strategies: StrategyHelper.getStrategies(),
        }, updateLoadChart.bind(this));
    }

    function renderSummary() {
        $.ajax({
            type: "POST",
            url: businessCaseTable.data('finishUrl')
        });
        $("#business_case_table .loading-spinner").removeClass("on");
        $("select#compare").prop('disabled', false);
    }

    function showLoadingSpinner() {
        $("#business_case_table .loading-spinner").addClass("on");
        $("select#compare").prop('disabled', true);
    }

    function pollBusinessCase() {
        new Poller({
            url: businessCaseTable.data('url'),
            data: {
                strategies: StrategyHelper.getStrategies()
            },
            first_data: {
                clear: true
            }
        }).poll().done(renderSummary).progress(showLoadingSpinner);
    }

    function toggleStrategies() {
        this.toggleLoading();
        loadChart.strategyShown = true;

        if (loadChart.strategyLoads === true) {
            return false;
        } else if (!StrategyHelper.anyStrategies()) {
            this.toggleLoading();

            if (changedStrategy) {
                LoadChartHelper.forceReload = true;
                loadChart.strategyShown = false;
                loadChart.reloadLast();

                pollBusinessCase.call(this);
            }
        } else {
            loadChart.strategyLoads = true;

            pollTree.call(this);
            pollBusinessCase.call(this);
        }
    }

    function updateStrategies() {
        var appliedStrategies = StrategyHelper.getStrategies();
        changedStrategy = false;

        $(".load-strategies li:not(.disabled) input[type=checkbox]").each(function () {
            if (appliedStrategies[$(this).val()] !== $(this).is(":checked")) {
                changedStrategy = true;
                return false;
            }
        });

        $(".load-strategies li:not(.disabled) input[type=checkbox]").each(function () {
            appliedStrategies[$(this).val()] = $(this).is(":checked");
        });

        $(".save_strategies.hidden").text(JSON.stringify(appliedStrategies));
    }

    StrategyToggler.prototype = {
        addOnChangeListener: function () {
            applyStrategyButton.prop('disabled', false);
            applyStrategyButton.on("click", this.applyStrategies.bind(this));
        },

        applyStrategies: function () {
            updateStrategies.call(this);
            toggleStrategies.call(this);
        },

        toggleLoading: function () {
            var loadingSpinner = $(".load-graph-wrapper .loading-spinner");
            loadingSpinner.toggleClass("on");

            applyStrategyButton.prop("disabled", loadingSpinner.hasClass("on"));
        },

        updateLoadChartWithStrategies: function (data) {
            updateLoadChart.call(this, data);
        },

        setStrategies: function () {
            var multiSelect = buildMultiSelect(),
                cappingInput = $("input[type=checkbox][value=capping_solar_pv]");

            savedStrategies = JSON.parse($(".save_strategies").text());

            multiSelect.multiselect('select', getSelectedItems());

            cappingInput.parents('a').append($(".slider-wrapper.hidden"));
            cappingInput.on("change", showSlider);

            showSlider.call(cappingInput);

            $("#solar_pv_capping").slider(sliderSettings)
                .slider('setValue', (savedStrategies.capping_fraction || 1) * 100);
        },

        clear: function () {
            var clearStrategies = true;
            $(".load-strategies input[type=checkbox]").each(function () {
                if ($(this).is(":checked")) {
                    clearStrategies = false;
                    return false;
                }
            });
            return clearStrategies;
        }
    };

    function StrategyToggler(thisLoadChart, urls) {
        loadChart = thisLoadChart;
        this.urls = urls;
        businessCaseTable = $("#business_case_table");
        applyStrategyButton = $("button.apply_strategies");
    }

    return StrategyToggler;
}());
