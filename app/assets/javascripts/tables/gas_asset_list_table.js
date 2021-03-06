/*globals Ajax,EditableTable*/

var GasAssetListTable = (function () {
    'use strict';

    function setCorrectUnit(part) {
        $(this).find("span.unit span").hide();
        $(this).find("span.unit span." + part).show();
    }

    function setAssetTypeOptions(data, initial) {
        var options = [],
            row = $(this).parents("tr");

        data.forEach(function (option) {
            options.push(
                $("<option/>").attr("value", option.type).html(option.type)
            );
        });

        // Reset the units of a gas asset to 0 when somebody changes the type
        if (!initial) {
            row.find("input[name='units']").val(0);
        }

        setCorrectUnit.call(row, row.find("select.part").val());

        row.find("select.type")
            .html(options)
            .val(function () {
                var type = $(this).data('type');

                return ((type === 'blank' || !initial) ? $(this).val() : type);
            });
    }

    function getAssetData(target) {
        var row = $(target).parents("tr"),
            assetData = {
                part: row.find("select.part").val(),
                pressure_level_index: row.find("select.pressure_level").val()
            };

        return assetData;
    }

    function getAssetTypes(e) {
        var gasData = [ getAssetData(e.target) ];

        Ajax.json(this.assetUrl, { gas_parts: gasData }, function (data) {
            setAssetTypeOptions.call(e.target, data[0], false);
        });
    }

    function getMultipleAssetTypes(data) {
        Ajax.json(this.assetUrl, { gas_parts: data }, function (data) {
            data.forEach(function (options, i) {
                setAssetTypeOptions.call($($("select.type")[i]), options, true);
            });
        });
    }

    function setInitialSelectBoxes() {
        var data = [];

        $(this.editableTable.selector).find("select.part").each(function () {
            data.push(getAssetData(this));
        });

        getMultipleAssetTypes.call(this, data);
    }

    function reloadGasAssetList(e) {
        var reloadButton = $(e.target).data();

        if (confirm(reloadButton.confirmation)) {
            Ajax.json(reloadButton.url, {}, function (data) {
                $("#gas_asset_list_asset_list").text(JSON.stringify(data));
                $("form.edit_gas_asset_list").submit();
            });
        }
    }

    function setEventListeners() {
        $(".btn.reload-gas-asset-list")
            .off('click')
            .on("click", reloadGasAssetList);

        $(this.editableTable.selector).find("select.part, select.pressure_level")
            .off("change")
            .on("change", getAssetTypes.bind(this));
    }

    GasAssetListTable.prototype = {
        append: function () {
            this.addEventListenerToForm();
            this.editableTable.append(this.updateTable.bind(this));

            setInitialSelectBoxes.call(this);
            setEventListeners.call(this);
        },

        addEventListenerToForm: function () {
            $('form.edit_gas_asset_list').on("ajax:success", function () {
                for (var graphId in window.graphs) {
                    window.graphs[graphId].reload();
                };
            });
        },

        updateTable: function () {
            setEventListeners.call(this);

            $("#gas_asset_list_asset_list")
                .text(JSON.stringify(this.editableTable.getData()));
        }
    };

    function GasAssetListTable(selector) {
        this.assetUrl      = $(selector).data('url');
        this.editableTable = new EditableTable(selector);
    }

    return GasAssetListTable;
}());
