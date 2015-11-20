/*globals document,TopologyStylesheet*/
var TopologyPreviewer = (function () {
    'use strict';

    var nodeIds = 0,
        diagonal = d3.svg.diagonal().projection(function (d) {
            return [d.x, d.y];
        });

    function clear() {
        $(this.topologyGraph).find("svg").remove();
    }

    function viewerWidth() {
        return this.currentStylesheet.width - this.currentStylesheet.margin.left * 2;
    }

    function updateTree() {
        var nodes = this.tree.nodes(this.root).reverse(),
            links = this.tree.links(nodes);

        nodes.forEach(function (d) {
            d.y = d.depth * this.lineSpace;
        }.bind(this));

        var node = this.svgGroup.selectAll("g.node").data(nodes, function (d) {
            return d.id || (d.id = ++nodeIds);
        });

        var nodeEnter = node.enter().append("g")
            .attr("class", "node")
            .attr("transform", function (d) {
                return "translate(" + d.x + "," + d.y + ")";
            })
            .classed('collapsed', function (d) {
                return d._children;
            });

        nodeEnter.append("circle")
            .attr("r", this.currentStylesheet.radius)
            .style("fill", this.currentStylesheet.nodeColor);

        if (this.currentStylesheet.renderLabels) {
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
                .style("fill-opacity", 1);
        }

        var link = this.svgGroup.selectAll("path.link")
            .data(links, function (d) {
                return d.target.id;
            });

        link.enter().insert("path", "g")
            .attr("class", "link")
            .attr("d", diagonal);
    }

    function zoomListener() { return; }

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
        return (this.currentStylesheet.height / this.depths);
    }

    function buildBaseSvg() {
        return d3.select(this.topologyGraph).append('svg')
            .attr('width', '100%')
            .attr('height', this.depths * this.lineSpace)
            .attr('class', 'overlay')
            .call(zoomListener)
            .on('wheel.zoom', null)
            .on('dblclick.zoom', null);
    }

    TopologyPreviewer.prototype = {
        preview: function () {
            clear.call(this);

            this.currentStylesheet = TopologyStylesheet[this.style];
            this.svgHeight         = 0;
            this.depths            = 0;
            this.svgWidth          = viewerWidth.call(this);
            this.data              = [this.presetData];
            this.root              = this.data[0];
            this.lineSpace         = Math.min(calculateLineHeight.call(this), 100);
            this.svg               = buildBaseSvg.call(this);
            this.svgGroup          = this.svg.append('g');

            this.svgGroup.attr('transform', function () {
                return "translate(" + this.currentStylesheet.margin.left + "," +
                                      this.currentStylesheet.margin.top + ")";
            }.bind(this));

            this.tree = d3.layout.tree().size([this.svgWidth, this.svgHeight]);
            updateTree.call(this);
        }
    };

    function TopologyPreviewer(topologyGraph, presetData, style) {
        this.topologyGraph = topologyGraph;
        this.presetData = presetData ? presetData.graph : JSON.parse($(this.topologyGraph).find(".data").text());
        this.style = style || "full";
        this.lineSpace = 0;
    }

    return TopologyPreviewer;
}());

$(document).on("page:change", function () {
    'use strict';

    if ($("div.topology-graph").length > 0) {
        new TopologyPreviewer(".topology-graph").preview();
    }
});
