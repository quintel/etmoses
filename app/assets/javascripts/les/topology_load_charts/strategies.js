/*global Ajax,StrategyHelper,Poller*/

var Strategies = (function () {
    'use strict';

    var savedStrategies,
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

    function saveSelectedStrategies(strategies) {
        Ajax.json(
            window.currentTree.strategiesUrl,
            { strategies: strategies }
        ).success(function() {
            if (StrategyHelper.anyStrategies()) {
                // When somebody changes the strategies but not blank
                window.currentTree.updateStrategies();
            } else {
                // When somebody blanks the strategies
                window.currentTree.treeGraph.clearStrategies().reload();
            }
        });
    }

    function updateStrategies() {
        var original = StrategyHelper.getStrategies(),
            updated  = strategiesFromForm();

        if (isChanged(original, updated)) {
            $(".save_strategies.hidden").text(JSON.stringify(updated));
            saveSelectedStrategies.call(this, updated);
        }
    }

    function isChanged(orig, updated) {
        for (var key in orig) {
            if (orig.hasOwnProperty(key) && updated[key] !== orig[key]) {
                return true
            }
        }

        return false;
    }

    function strategiesFromForm() {
        var parentEl   = $('.load-strategies li:not(.disabled)'),
            strategies = {};

        parentEl.find('input[type=checkbox]').each(function () {
            strategies[$(this).val()] = $(this).is(":checked");
        });

        parentEl.find('input[type=text]').each(function () {
            strategies[$(this).attr('name')] = $(this).val();
        });

        if (strategies.capping_fraction) {
            strategies.capping_fraction =
                parseFloat(strategies.capping_fraction) / 100;
        }

        return strategies;
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

    function Strategies() {
        $("button.apply_strategies").on("click", updateStrategies.bind(this));

        setStrategies.call(this);

        return StrategyHelper.getStrategies();
    }

    return Strategies;
}());
