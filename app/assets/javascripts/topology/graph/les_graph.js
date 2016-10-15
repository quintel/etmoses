/*globals ChartRenderer,CSV,ETHelper,LesGraph,LocalSettings,Topology*/

Topology.LesGraph = (function () {
    'use strict';

    function buildBase() {
        $('.loading').remove();
        $(this.scope).find("svg").remove();

        this.buildBaseSVG();
    }

    function reloadLast() {
        if (this.lastClicked) {
            this.showChart(this.lastClicked);
        }
    }

    function visit(parent, visitFn, childrenFn) {
        if (!parent) { return; }

        var children, count, i;

        visitFn(parent);
        children = childrenFn(parent);

        if (children) {
            count = children.length;

            for (i = 0; i < count; i += 1) {
                visit(children[i], visitFn, childrenFn);
            }
        }
    }

    // Shows or hides children depending on the current state.
    function toggleChildren(d) {
        if (d.children) {
            d.collapsed_children = d.children;
            d.children = null;
        } else if (d.collapsed_children) {
            d.children = d.collapsed_children;
            d.collapsed_children = null;
        }

        return d;
    }

    function updateTreeData() {
        visit(this.treeData, toggleChildren, function (n) {
            return n.collapsed_children;
        });
    }

    function calculateMaxLabelLength() {
        visit(this.treeData,
            function (d) {
                this.maxLabelLength = Math.max(d.name.length, this.maxLabelLength || 0);

                if (d.children && d.children.length === 0) {
                    d.children = null;
                }
            }.bind(this),
            function (d) {
                return d.children && d.children.length > 0 ? d.children : null;
            });
    }

    function setNodeLabelY(d) {
        return d.children ? -20 : 20;
    }

    function isOverCapacity(d) {
        var load = (d.electricity_features || d.electricity),
            // add 1e-5 so that we don't wrongly highlight nodes whose load has tiny
            // variations due to floating-point arithmetic.
            capacity = (d.capacity * (d.units || 1)) + 1e-5;

        return load && (d.capacity &&
            (d3.max(load.total) > capacity || d3.min(load.total) < -capacity));
    }

    function setNodeClass(data) {
        var nodeClass = ("node " + data.stakeholder + " n" + data.id);

        if (data.node_selected) {
            nodeClass += " selected";
        }
        return nodeClass;
    }

    function recurseToggle(n) {
        toggleChildren(n);

        if (n.children && n.children.length > 0) {
            n.children.forEach(recurseToggle);
        }
    }

    // Toggle children on click.
    function click(d) {
        // Click suppressed
        if ((d3.event && d3.event.defaultPrevented)
                || !d.electricity_basic
                || window.currentTree.loading) {
            return false;
        }

        window.localSettings.set('current_chart_id', d.id);

        this.lastClicked = d;
        this.showChart(d);
    }

    function dblClick(d) {
        if (d3.event.defaultPrevented) { return; } // click suppressed

        if (d.collapsed_children || d.children) {
            toggleChildren(d);
            this.update(d);
            this.center(d);
        }
    }

    function createD3Tree() {
        var d3tree = d3.layout.tree().nodeSize([50, 50]);

        return d3tree.sort(function (a, b) {
            return b.name.toLowerCase() < a.name.toLowerCase() ? 1 : -1;
        });
    }

    function setLastClickedNode() {
        var currentNode = this.root,
            settings    = window.localSettings.getAll();

        if (settings && settings.current_chart_id) {
            ETHelper.eachNode([this.root], function (node) {
                if (node.id === settings.current_chart_id) {
                    currentNode = node;
                    return false;
                }
            });
        }

        this.lastClicked = currentNode;
        reloadLast.call(this);
    }

    LesGraph.prototype = $.extend({}, Topology.Base.prototype, {
        draw: function (treeData) {
            this.treeData = treeData.graph;
            this.root     = this.treeData;
            this.root.x0  = this.height / 2;
            this.root.y0  = 0;

            $("a.dropdown-toggle").first().removeClass("disabled");

            buildBase.call(this);

            calculateMaxLabelLength.call(this);
            updateTreeData.call(this);
            recurseToggle(this.treeData);

            this.update(this.root);
            this.center(this.root);

            setLastClickedNode.call(this);

            return this;
        },

        zoomListener: function () {
            return d3.behavior.zoom()
                .scaleExtent([0.1, 3]).on('zoom', function () {
                    this.svgGroup.attr('transform',
                        'translate(' + d3.event.translate + ')' +
                        'scale(' + d3.event.scale + ')');
                }.bind(this));
        },

        clearStrategies: function () {
            ETHelper.eachNode([this.root], function (node) {
                delete node.electricity_features;
                delete node.gas_features;
                delete node.heat_features;
            });

            return this;
        },

        reload: function (data) {
            this.treeData = Topology.NetworkToTree.toTree.call(this, data);
            this.root     = this.treeData;

            this.update(this.root);

            setLastClickedNode.call(this);
        },

        showChart: function (d) {
            new ChartRenderer(this, d).show();
        },

        update: function (source) {
            // Compute the new height, function counts total children of root node
            // and sets tree height accordingly. This prevents the layout looking
            // squashed when new nodes are made visible or looking sparse when nodes
            // are removed. This makes the layout more consistent.
            //
            var nodeIds = 0,
                node,
                nodes,
                links,
                nodeEnter,
                nodeUpdate,
                nodeExit,
                link;

            // Compute the new tree layout.
            nodes = this.tree.nodes(this.root).reverse();
            links = this.tree.links(nodes);

            // Set widths between levels based on maxLabelLength.
            nodes.forEach(function (d) {
                // alternatively to keep a fixed scale one can set a fixed depth per
                // level. Normalize for fixed-depth by commenting out below line>
                // d.y = (d.depth * 175); //175px per level.
                d.y = (d.depth * (this.maxLabelLength * 8));
            }.bind(this));

            // Update the nodes…
            node = this.svgGroup.selectAll('g.node').data(nodes, function (d) {
                return d.id || (d.id = ++nodeIds);
            });

            node.classed('collapsed', function (d) {
                return d.collapsed_children;
            });

            // Enter any new nodes at the parent's previous position.
            nodeEnter = node.enter().append('g')
                .call(this.dragListener)
                .attr('class', setNodeClass)
                .classed('collapsed', function (d) {
                    // We have to run the "collapsed" function again (it is already
                    // defined above), as the above version does not run the first
                    // time the update() function is called.
                    return d.collapsed_children;
                })
                .attr('transform', function () {
                    return 'translate(' + source.x0 + ',' + source.y0 + ')';
                })
                .on('dblclick', dblClick.bind(this))
                .on('click', click.bind(this));

            node.classed('exceedance', isOverCapacity);

            nodeEnter.append('circle')
                .attr('class', 'nodeCircle')
                .attr('r', 0);

            nodeEnter.append('text')
                .attr('y', setNodeLabelY)
                .attr('dy', '.38em')
                .attr('class', 'nodeText')
                .style('fill-opacity', 0)
                .attr('text-anchor', 'middle')
                .text(function (d) {
                    return d.name;
                });

            // Update the text to reflect whether node has children or not.
            node.select('text')
                .attr('y', setNodeLabelY)
                .attr('text-anchor', 'middle')
                .text(function (d) {
                    return d.name;
                });

            // Change the circle fill depending on whether it has children and is collapsed
            node.select('circle.nodeCircle').attr('r', this.radius);

            // Transition nodes to their new position.
            nodeUpdate = node.transition()
                .duration(this.duration).ease(this.ease)
                .attr('transform', function (d) {
                    return 'translate(' + d.x + ',' + d.y + ')';
                });

            // Fade the text in
            nodeUpdate.select('text').style('fill-opacity', 1);

            // Transition exiting nodes to the parent's new position.
            nodeExit = node.exit().transition()
                .duration(this.duration).ease(this.ease)
                .attr('transform', function () {
                    return 'translate(' + source.x + ',' + source.y + ')';
                })
                .remove();

            nodeExit.select('circle').attr('r', 0);
            nodeExit.select('text').style('fill-opacity', 0);

            // Update the links…
            link = this.svgGroup.selectAll('path.link').data(links, function (d) {
                return d.target.id;
            });

            // Enter any new links at the parent's previous position.
            link.enter().insert('path', 'g')
                .attr('class', 'link')
                .attr('d', function () {
                    var o = {
                        x: source.x0,
                        y: source.y0
                    };
                    return this.diagonal({
                        source: o,
                        target: o
                    });
                }.bind(this));

            // Transition links to their new position.
            link.transition()
                .duration(this.duration).ease(this.ease)
                .attr('d', this.diagonal);

            // Transition exiting nodes to the parent's new position.
            link.exit().transition()
                .duration(this.duration).ease(this.ease)
                .attr('d', function () {
                    var o = {
                        x: source.x,
                        y: source.y
                    };
                    return this.diagonal({
                        source: o,
                        target: o
                    });
                }.bind(this))
                .remove();

            // Stash the old positions for transition.
            nodes.forEach(function (d) {
                d.x0 = d.x;
                d.y0 = d.y;
            });
        },

        root: undefined,
        lastClicked: undefined,
        strategyLoads: false,
        strategyShown: false,
        treeData: {}
    });

    function LesGraph(scope) {
        Topology.Base.call(this, scope);

        this.scope        = scope;
        this.id           = "les-graph";
        this.height       = 700;
        this.width        = 550;
        this.radius       = 7.5;
        this.duration     = 250;
        this.ease         = 'cubic-out';
        this.tree         = createD3Tree();
    }

    return LesGraph;
}());
