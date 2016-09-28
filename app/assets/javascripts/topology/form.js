Topology.Form = (function () {
    'use strict';

    var editableFields = [
        "name", "stakeholder", "investment_cost",
        "technical_lifetime", "capacity"
    ];

    function forEachField(iterator) {
        editableFields.forEach(function (name) {
            iterator.call(this.scope.find("#" + name), name);
        }.bind(this));
    }

    function onUpdateInfo() {
        var obj = {};

        forEachField.call(this, function (name) {
            obj[name] = this.val();
        });

        window.TopologyEditor.graphEditor.updateNode(obj);
    }

    Form.prototype = {
        initialize: function () {
            this.scope[0].addEventListener('change', onUpdateInfo.bind(this), true);
        },

        show: function (d) {
            forEachField.call(this, function (name) {
                if (d.errors && d.errors[name]) {
                    this.addClass("invalid");
                    this.attr('title', d.errors[name]);
                }
                this.val(d[name]);
            });
        }
    }

    function Form(scope) {
        this.scope = scope.find(".node-information");
    }

    return Form;
}());
