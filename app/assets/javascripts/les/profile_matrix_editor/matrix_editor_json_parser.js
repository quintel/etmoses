var MatrixEditorJSONParser = (function () {
    'use strict'

    // Takes data as scope, component as a String.
    // Filters out all the keys that start with the component.
    //
    // Returns an Array
    function keysForComponent(component) {
        return Object.keys(this).filter(function (k) {
            return k.indexOf(component) === 0;
        });
    }

    function buildComponent(component) {
        var object = { type: component };

        keysForComponent.call(this, component).forEach(function (key) {
            object[key.replace(component + '_', '')] = this[key];

            delete this[key];
        }.bind(this));

        return object;
    };

    function dataFromTarget(target) {
        var data = $(target).underscorizedData();

        if (data.components && data.components.length > 0) {
            data.components = data.components.map(buildComponent.bind(data));
        } else {
            delete data.components;
        }

        for (var key in data) {
            if (data[key] === undefined || data[key] === '') {
                delete data[key];
            }
        }

        delete data.stick_to_composite;
        delete data.includes;

        return data;
    }

    function getTableProfile() {
        return $(".technologies .technology:not(.hidden)").toArray()
            .map(dataFromTarget);
    }

    MatrixEditorJSONParser.prototype = {
        parse: function () {
            var tableProfile = getTableProfile(),
                groupedByNode = ETHelper.groupBy(tableProfile, 'node');

            $("#technology_distribution").text(JSON.stringify(tableProfile));
            $("#testing_ground_technology_profile").text(JSON.stringify(groupedByNode));
        }
    }

    function MatrixEditorJSONParser() {
        return;
    }

    return MatrixEditorJSONParser;
}());
