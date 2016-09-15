/* Basic class draws D3 svg element
 */

Topology.GraphEditor = (function () {
    'use strict';

    var nodeIds = 0,
        diagonal = d3.svg.diagonal().projection(function (d) {
            return [d.x, d.y];
        });

    function zoomListener() { return; }

    function drawBaseSvg() {
        return d3.select(this.scope).append('svg')
            .attr('class', 'overlay')
            .attr('width', this.width)
            .attr('height', this.height)
            .attr('viewBox', '0 0 ' + this.width + ' ' + this.height)
            .call(zoomListener)
            .on('wheel.zoom', null)
            .on('dblclick.zoom', null);
    }

    GraphEditor.prototype = {
        draw: function () {
            this.svg   = drawBaseSvg.call(this);
            this.group = this.svg.append('g');
            this.tree  = d3.layout.tree().size([this.width, this.height]);
            this.root  = {};

            this.group.attr('transform', function () {
                return "translate(" + 20 + "," +
                                      20 + ")";
            }.bind(this));

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

            node = this.group.selectAll("g.node").data(nodes, function (d) {
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
                .attr("r", 10)
                .style("fill", "#CCC")
                .style("stroke", "steelblue")
                .style("stroke-width", "2px");

            link = this.group.selectAll("path.link")
                .data(links, function (d) {
                    return d.target.id;
                });

            link.enter().insert("path", "g")
                .attr("class", "link")
                .attr("fill", "none")
                .attr("stroke", "#ccc")
                .attr("stroke-width", "2px")
                .attr("d", diagonal);

        }
    };

    function GraphEditor(scope) {
        this.scope  = scope.find('.graph-editor')[0];
        this.width  = 684;
        this.height = 500;
    }

    return GraphEditor;
}());
