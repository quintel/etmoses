/*globals EditorGraph,Topology*/

Topology.EditorGraph = (function () {
    'use strict';

    function plusPath(size) {
        return 'M0,-' + size + ' V' + size +' M-' + size + ',0 H' + size;
    }

    EditorGraph.prototype = $.extend({}, Topology.Base.prototype, {
        draw: function () {
            this.buildBaseSVG();

            this.svgGroup.attr('transform', "translate(0, 40)");

            this.nodeIds = this.maxId();
            this.tree    = d3.layout.tree().nodeSize([80, 0]);

            this.update();

            this.center(this.data);
            window.TopologyEditor.form.show(this.data);
        },

        update: function () {
            var node,
                nodeEnter,
                link,
                addSize = 6,
                nodes   = this.tree.nodes(this.data),
                links   = this.tree.links(nodes);

            nodes.forEach(function (d) {
                d.y = d.depth * this.lineSpace;
            }.bind(this));

            this.svgGroup.selectAll("g.node, path.link").remove();

            node = this.svgGroup.selectAll("g.node").data(nodes, function (d) {
                return d.id || (d.id = ++this.nodeIds);
            }.bind(this));

            nodeEnter = node.enter().append("g")
                .attr("class", function (d) {
                    if (d.focus) {
                        window.TopologyEditor.graphEditor.focusId = d.id;
                        return "node focus";
                    } else {
                        return "node";
                    }
                })
                .attr("transform", function (d) {
                    return "translate(" + d.x + "," + d.y + ")";
                });

            // append a + button
            nodeEnter.append("path")
                .attr("class", "add-button")
                .attr('d', plusPath(addSize))
                .attr('stroke', 'green')
                .attr('stroke-width', 3)
                .attr('fill', 'none')
                .attr('transform', 'translate(22, 0)')
                .on('click', function (d) {
                    window.TopologyEditor.graphEditor.addNode(d);
                })
                .on("mouseover", function () {
                    d3.select(this).style("cursor", "pointer");
                })
                .on("mouseout", function () {
                    d3.select(this).style("cursor", "default");
                });

            nodeEnter.append("circle")
                .attr("r", this.radius)
                .attr("class", function (d) {
                    if (d.errors && Object.keys(d.errors).length > 0) {
                        return "invalid";
                    }
                })
                .on('click', function (d) {
                    window.TopologyEditor.graphEditor.focusId = d.id;
                    window.TopologyEditor.form.show(d);

                    d3.selectAll('g.node').attr("class", "node");
                    d3.select(this.parentNode).attr("class", "node focus");
                })
                .on("mouseover", function () {
                    d3.select(this).style("cursor", "pointer");
                })
                .on("mouseout", function () {
                    d3.select(this).style("cursor", "default");
                });

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
        },

        zoomListener: function () {
            return d3.behavior.zoom()
                .scaleExtent([0.1, 3]).on('zoom', function () {
                    this.svgGroup.attr('transform',
                        'translate(' + d3.event.translate + ')' +
                        'scale(' + d3.event.scale + ')');
                }.bind(this));
        }
    });

    function EditorGraph(scope, data) {
        Topology.Base.call(this, scope);

        this.width     = 684;
        this.height    = 500;
        this.lineSpace = 80;
        this.radius    = 10;
        this.data      = data;
    }

    return EditorGraph;
}());
