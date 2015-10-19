var TopologyPreviewer = (function() {
    'use strict';

    var nodeIds = 0,
        maxLabelLength = 20,
        ease = 'cubic-out';

    var diagonal = d3.svg.diagonal()
        .projection(function(d) {
            return [d.x, d.y];
        });

    TopologyPreviewer.prototype = {
        preview: function() {
            clear.call(this);

            this.currentStylesheet = TopologyStylesheet[this.style];
            this.svgHeight = 0;
            this.svgWidth = viewerWidth.call(this);
            this.svg = buildBaseSvg.call(this);
            this.data = [this.presetData];
            this.root = this.data[0];
            this.lineSpace = Math.min(calculateLineHeight.call(this), 100);

            this.svgGroup = this.svg.append('g');
            this.svgGroup.attr('transform', function(d) {
                return "translate(" + this.currentStylesheet.margin.left + "," + this.currentStylesheet.margin.top + ")";
            }.bind(this));

            this.tree = d3.layout.tree().size([this.svgWidth, this.svgHeight]);
            updateTree.call(this, this.root);
        }
    };

    function clear() {
        $(this.topologyGraph).find("svg").remove();
    };

    function updateTree(source) {
        var nodes = this.tree.nodes(this.root).reverse(),
            links = this.tree.links(nodes);

        nodes.forEach(function(d) {
            d.y = d.depth * this.lineSpace;
        }.bind(this));

        var node = this.svgGroup.selectAll("g.node")
            .data(nodes, function(d) {
                return d.id || (d.id = ++nodeIds);
            });

        var nodeEnter = node.enter().append("g")
            .attr("class", "node")
            .attr("transform", function(d) {
                return "translate(" + d.x + "," + d.y + ")";
            })
            .classed('collapsed', function(d) {
                return d._children;
            });

        nodeEnter.append("circle")
            .attr("r", this.currentStylesheet.radius)
            .style("fill", this.currentStylesheet.nodeColor);

        if (this.currentStylesheet.renderLabels) {
            nodeEnter.append("text")
                .attr("x", function(d) {
                    return d.children || d._children ? -13 : 13;
                })
                .attr("dy", ".35em")
                .attr("text-anchor", function(d) {
                    return d.children || d._children ? "end" : "start";
                })
                .text(function(d) {
                    return d.name;
                })
                .style("fill-opacity", 1);
        };

        var link = this.svgGroup.selectAll("path.link")
            .data(links, function(d) {
                return d.target.id;
            });

        link.enter().insert("path", "g")
            .attr("class", "link")
            .attr("d", diagonal);
    };

    function buildBaseSvg() {
        return d3.select(this.topologyGraph).append('svg')
            .attr('width', '100%')
            .attr('height', this.currentStylesheet.svgHeight)
            .attr('class', 'overlay')
            .call(zoomListener)
            .on('wheel.zoom', null)
            .on('dblclick.zoom', null);
    };

    function dragListener() {};

    function zoomListener() {};

    function calculateLineHeight() {
        var depths = depthCount.call(this, this.presetData, 0);
        return (this.currentStylesheet.height / depths)
    };

    function viewerWidth() {
        return this.currentStylesheet.width - this.currentStylesheet.margin.left * 2;
    };

    function depthCount(d, level) {
        level = level || 1;

        if (d.children && d.children.length) {
            return d3.max(d.children.map(function(child) {
                return depthCount(child, level + 1);
            }));
        } else {
            return level;
        }
    };

    function TopologyPreviewer(_topologyGraph, _presetData, _style) {
        this.topologyGraph = _topologyGraph;
        this.presetData = _presetData ? _presetData.graph : JSON.parse($(topologyGraph).find(".data").text());
        this.style = _style || "full";
        this.lineSpace = 0;
    };

    return TopologyPreviewer;
}());

$(document).on("page:change", function() {
    if ($("div.topology-graph").length > 0) {
        new TopologyPreviewer(".topology-graph").preview();
    }
});
