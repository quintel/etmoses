/*globals PreviewGraph,Topology*/

Topology.PreviewGraph = (function () {
    'use strict';

    var nodeIds = 0;

    function clear() {
        $(this.scope).find("svg").remove();
    }

    function viewerWidth() {
        return $(this.scope).width() - this.margin.left * 2;
    }

    function depthCount(d, level) {
        level = level || 1;

        if (d.children && d.children.length) {
            return d3.max(d.children.map(function (child) {
                return depthCount(child, level + 1);
            }));
        } else {
            return level;
        }
    }

    function calculateLineHeight() {
        this.depths = depthCount.call(this, this.presetData, 0);
        return (this.height / this.depths);
    }

    PreviewGraph.prototype = $.extend({}, Topology.Base.prototype, {
        draw: function () {
            clear.call(this);

            this.svgHeight         = 0;
            this.depths            = 0;
            this.svgWidth          = viewerWidth.call(this);
            this.data              = [this.presetData];
            this.root              = this.data[0];
            this.lineSpace         = Math.min(calculateLineHeight.call(this), 100);

            this.buildBaseSVG();

            this.svgGroup.attr('transform', function () {
                return "translate(" + this.margin.left + "," +
                                      this.margin.top + ")";
            }.bind(this));

            this.tree = d3.layout.tree().size([this.svgWidth, this.svgHeight]);
            this.update();
        },

        update: function () {
            var node,
                nodeEnter,
                link,
                nodes = this.tree.nodes(this.root).reverse(),
                links = this.tree.links(nodes);

            nodes.forEach(function (d) {
                d.y = d.depth * this.lineSpace;
            }.bind(this));

            node = this.svgGroup.selectAll("g.node").data(nodes, function (d) {
                return d.id || (d.id = ++nodeIds);
            });

            nodeEnter = node.enter().append("g")
                .attr("class", "node")
                .attr("transform", function (d) {
                    return "translate(" + d.x + "," + d.y + ")";
                })
                .classed('collapsed', function (d) {
                    return d._children;
                });

            nodeEnter.append("circle")
                .attr("r", this.radius)
                .style("fill", this.nodeColor)
                .style("stroke", "steelblue")
                .style("stroke-width", "2px");

            if (this.renderLabels) {
                nodeEnter.append("text")
                    .attr("x", function (d) {
                        return d.children || d._children ? -13 : 13;
                    })
                    .attr("dy", ".35em")
                    .attr("text-anchor", function (d) {
                        return d.children || d._children ? "end" : "start";
                    })
                    .text(function (d) {
                        return d.name;
                    })
                    .style("fill-opacity", 1)
                    .style("font", "12px sans-serif");
            }

            link = this.svgGroup.selectAll("path.link")
                .data(links, function (d) {
                    return d.target.id;
                });

            link.enter().insert("path", "g")
                .attr("class", "link")
                .attr("fill", "none")
                .attr("stroke", "#ccc")
                .attr("stroke-width", "2px")
                .attr("d", this.diagonal);
        }
    });

    function PreviewGraph(scope) {
        Topology.Base.call(this, scope);

        this.id            = "topology-graph-full";
        this.scope         = scope;
        this.presetData    = $(this.scope).data("graph");
        this.lineSpace     = 0;
        this.width         = 1140;
        this.height        = 600;
        this.svgHeight     = '520px';
        this.renderLabels  = true;
        this.margin        = { left: 100, top: 15 };
        this.radius        = 8;
        this.nodeColor     = "#FFF";
    }

    return PreviewGraph;
}());

$(document).on("page:change", function () {
    'use strict';

    if ($("div.template-graph").length > 0) {
        new Topology.PreviewGraph(".template-graph").draw();
    }
});
