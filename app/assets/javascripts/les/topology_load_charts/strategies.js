/*global Ajax,StrategyHelper,LoadChartHelper,Poller,TreeFetcher*/
var Strategies = (function () {
    'use strict';

    var applyStrategyButton, businessCaseTable, savedStrategies,
        changedStrategy,
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

    function clearStrategiesFromChart() {
        window.currentTree.treeGraph.clearStrategies().reload();
    }

    function pollTree() {
        window.currentTree.set(window.currentTree.resolution).updateStrategies();
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
        var businessCaseOptions = {
            url: businessCaseTable.data('url'),
            data: {
                strategies: StrategyHelper.getStrategies()
            },
            first_data: {
                clear: true
            }
        };

        new Poller(businessCaseOptions).poll()
            .done(renderSummary)
            .progress(showLoadingSpinner);
    }

    function saveSelectedStrategies(toggle, strategies) {
        var self = this;

        Ajax.json(
            window.currentTree.strategiesUrl,
            { strategies: strategies },
            function () {
                if (toggle) {
                    self.toggleLoading();
                }
            }
        );
    }

    function toggleStrategies(appliedStrategies) {
        this.toggleLoading();

        if (changedStrategy && !StrategyHelper.anyStrategies()) {
            LoadChartHelper.forceReload = true;

            saveSelectedStrategies.call(this, true, appliedStrategies);
            clearStrategiesFromChart.call(this);
            pollBusinessCase.call(this);
        } else if (changedStrategy) {
            pollTree.call(this);
            pollBusinessCase.call(this);
        } else {
            this.toggleLoading();
        }
    }

    function updateStrategies(appliedStrategies) {
        $(".load-strategies li:not(.disabled) input[type=checkbox]").each(function () {
            appliedStrategies[$(this).val()] = $(this).is(":checked");
        });

        $(".save_strategies.hidden").text(JSON.stringify(appliedStrategies));
        toggleStrategies.call(this, appliedStrategies);
    }

    function setChangedStrategy() {
        var appliedStrategies = StrategyHelper.getStrategies();

        changedStrategy = false;

        $(".load-strategies li:not(.disabled) input[type=checkbox]").each(function () {
            if (appliedStrategies[$(this).val()] !== $(this).is(":checked")) {
                changedStrategy = true;
                return false;
            }
        });

        updateStrategies.call(this, appliedStrategies);
    }

    function setStrategies() {
        var multiSelect = buildMultiSelect(),
            cappingInput = $("input[type=checkbox][value=capping_solar_pv]");

        savedStrategies = JSON.parse($(".save_strategies").text());

        multiSelect.multiselect('select', getSelectedItems());

        cappingInput.parents('a').append($(".slider-wrapper.hidden"));
        cappingInput.on("change", showSlider);

        showSlider.call(cappingInput);

        $("#solar_pv_capping").slider(sliderSettings)
            .slider('setValue', (savedStrategies.capping_fraction || 1) * 100);
    }

    function addOnChangeListener() {
        applyStrategyButton.prop('disabled', false);
        applyStrategyButton.on("click", setChangedStrategy.bind(this));
    }

    Strategies.prototype = {
        toggleLoading: function () {
            var loadingSpinner = $(".load-graph-wrapper .loading-spinner");
            loadingSpinner.toggleClass("on");

            applyStrategyButton.prop("disabled", loadingSpinner.hasClass("on"));
        }
    };

    function Strategies() {
        applyStrategyButton = $("button.apply_strategies");
        businessCaseTable   = $("#business_case_table");

        setStrategies.call(this);
        addOnChangeListener.call(this);
    }

    return Strategies;
}());
