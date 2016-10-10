/*globals NodeInterface,Topology*/

Topology.NodeInterface = (function () {
    'use strict';

    NodeInterface.prototype = {
        initialize: function () {
            this.scope.find(".remove-node").off("click").on("click", function (e) {
                e.preventDefault();

                window.TopologyEditor.graphEditor.deleteNode();
            });

            this.scope.find(".add-node").off("click").on("click", function (e) {
                e.preventDefault();

                window.TopologyEditor.graphEditor.addNode();
            });
        },

        reposition: function () {
            var interfaceX,
                interfaceY,
                focusNode     = $("g.node.focus"),
                circle        = focusNode.find("circle"),
                circleRadius  = parseInt(circle.attr('r'), 10),
                parent        = focusNode.parents("svg"),
                focusNodeRect = focusNode[0].getBoundingClientRect(),
                parentRect    = parent[0].getBoundingClientRect();

            interfaceX = parentRect.left - focusNodeRect.left;
            interfaceY = parentRect.top  - focusNodeRect.top;

            this.scope.css({
                left: -interfaceX - (this.scope.width() / 2) + circleRadius,
                top: -interfaceY - 35
            });
        }
    };

    function NodeInterface(scope) {
        this.scope  = scope.find(".node-interface");
    }

    return NodeInterface;
}());
