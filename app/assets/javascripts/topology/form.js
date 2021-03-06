/*globals Form,Topology*/

Topology.Form = (function () {
    'use strict';

    var editableFields = [
        "name", "stakeholder", "investment_cost",
        "technical_lifetime", "capacity", "units"
    ];

    function forEachField(iterator) {
        editableFields.forEach(function (name) {
            iterator.call(this.scope.find("#" + name), name);
        }.bind(this));
    }

    function onUpdateInfo() {
        var obj = {};

        forEachField.call(this, function (name) {
            obj[name] = this.rawValue();
        });

        window.TopologyEditor.graphEditor.updateNode(obj);
    }

    Form.prototype = {
        initialize: function () {
            this.scope[0].addEventListener('change', onUpdateInfo.bind(this), true);
        },

        show: function (d) {
            var profile;

            forEachField.call(this, function (name) {
                this.toggleClass("invalid", !!(d.errors && d.errors[name]))
                    .attr('title', d.errors ? d.errors[name] : "")
                    .val(d[name]);
            });

            if (window.TopologyEditor.isRemote) {
                profile = JSON.parse($("textarea.topology-graph").text());

                this.nameInput.prop("disabled",
                    (!!profile[d.name] && profile[d.name].length > 0));
            }
        },

        markAsEditing: function () {
            if (window.TopologyEditor.isRemote) {
                this.tab.markAsEditing();
            }
        }
    };

    function Form(scope) {
        this.tab       = new Tab("#topology");
        this.form      = scope.parents('form');
        this.scope     = scope.find(".node-information");
        this.nameInput = this.scope.find("input#name");
    }

    return Form;
}());
