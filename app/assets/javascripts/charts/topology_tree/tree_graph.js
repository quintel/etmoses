var TreeGraph = (function(){
  var _self, container, dragListener, zoomListener, node, baseSvg, tree, diagonal,
      svgGroup;

  var maxLabelLength  = 0,
      maxViewerHeight = 500,
      viewerHeight    = 615,
      viewerWidth     = 500,
      nodeIds         = 0,
      duration        = 250,
      nodeSize        = 50,
      ease            = 'cubic-out',
      levelWidth      = [1];

  TreeGraph.prototype = {
    showGraph: function(){
      buildBase();
      transformData.call(this);

      new StrategyToggler(this).addOnChangeListener();

      // Layout the tree initially and center on the root node.
      this.update(this.root);

      // Center the diagram with an offset such that *children* of the root will
      // appear to be in the center.
      centerNode(this.root);
    },

    showChart: function(d) {
      reloadCharts();

      var uniqueId = ("chart-id-" + d.id);
      var existingLoadPlatform = $(".load-graph ." + uniqueId);

      $(".load-graph .chart").hide();

      if(existingLoadPlatform.length > 0){
        existingLoadPlatform.show();
        LoadChartHelper.updateBrush(d.id);
        LoadChartHelper.toggleCapacity(d.id);
      }
      else{
        addNewLoadChartPlatform.call(this, uniqueId, d);
      };
    },

    update: function(source) {
      // Compute the new height, function counts total children of root node
      // and sets tree height accordingly. This prevents the layout looking
      // squashed when new nodes are made visible or looking sparse when nodes
      // are removed. This makes the layout more consistent.
      //
      _self = this;

      var newHeight, nodes, links, nodeEnter, nodeUpdate, nodeExit, link;

      // Fills the levelWidth area with all the nodes child counts
      childCount(0, this.root);

      // Compute the new tree layout.
      nodes = tree.nodes(this.root).reverse();
      links = tree.links(nodes);

      // Set widths between levels based on maxLabelLength.
      nodes.forEach(function(d) {
        // alternatively to keep a fixed scale one can set a fixed depth per
        // level. Normalize for fixed-depth by commenting out below line>
        // d.y = (d.depth * 175); //175px per level.
        d.y = (d.depth * (maxLabelLength * 8));
      });

      // Update the nodes…
      node = svgGroup.selectAll('g.node')
        .data(nodes, function(d) { return d.id || (d.id = ++nodeIds); });

      node.classed('collapsed', function(d) { return d._children; });

      // Enter any new nodes at the parent's previous position.
      nodeEnter = node.enter().append('g')
        .call(dragListener)
        .attr('class', setNodeClass)
        .classed('collapsed', function(d) {
          // We have to run the "collapsed" function again (it is already
          // defined above), as the above version does not run the first
          // time the update() function is called.
          return d._children;
        })
        .attr('transform', function(d) {
          return 'translate(' + source.x0 + ',' + source.y0 + ')';
        })
        .on('dblclick', dblClick)
        .on('click', click);

      node.classed('exceedance', overCapacity);

      nodeEnter.append('circle')
        .attr('class', 'nodeCircle')
        .attr('r', 0)

      nodeEnter.append('text')
        .attr('y', setNodeLabelY)
        .attr('dy', '.38em')
        .attr('class', 'nodeText')
        .style('fill-opacity', 0)
        .attr('text-anchor', 'middle')
        .text(function(d) { return d.name; });

      // Update the text to reflect whether node has children or not.
      node.select('text')
        .attr('y', setNodeLabelY)
        .attr('text-anchor', 'middle')
        .text(function(d) { return d.name; });

      // Change the circle fill depending on whether it has children and is collapsed
      node.select('circle.nodeCircle').attr('r', 7.5);

      // Transition nodes to their new position.
      nodeUpdate = node.transition()
        .duration(duration).ease(ease)
        .attr('transform', function(d) {
          return 'translate(' + d.x + ',' + d.y + ')';
        });

      // Fade the text in
      nodeUpdate.select('text').style('fill-opacity', 1);

      // Transition exiting nodes to the parent's new position.
      nodeExit = node.exit().transition()
        .duration(duration).ease(ease)
        .attr('transform', function(d) {
          return 'translate(' + source.x + ',' + source.y + ')';
        })
        .remove();

      nodeExit.select('circle').attr('r', 0);
      nodeExit.select('text').style('fill-opacity', 0);

      // Update the links…
      link = svgGroup.selectAll('path.link').data(links, function(d) {
               return d.target.id;
             });

      // Enter any new links at the parent's previous position.
      link.enter().insert('path', 'g')
        .attr('class', 'link')
        .attr('d', function(d) {
          var o = { x: source.y0, y: source.x0 };
          return diagonal({ source: o, target: o });
        });

      // Transition links to their new position.
      link.transition()
        .duration(duration).ease(ease)
        .attr('d', diagonal);

      // Transition exiting nodes to the parent's new position.
      link.exit().transition()
        .duration(duration).ease(ease)
        .attr('d', function(d) {
          var o = { x: source.y, y: source.x };
          return diagonal({ source: o, target: o });
        })
        .remove();

      // Stash the old positions for transition.
      nodes.forEach(function(d) { d.x0 = d.x; d.y0 = d.y; });
    },

    root: undefined,
    lastClicked: undefined,
    strategyLoads: false,
    strategyShown: false
  };

  function setNodeLabelY(d){
    return d.children ? -20 : 20;
  };

  function buildBase(){
    $('.loading').remove();

    baseSvg = createBaseSvg();
    svgGroup = baseSvg.append('g');
  };

  function createBaseSvg(){
    return d3.select(container).append('svg')
      .attr('width', viewerWidth)
      .attr('height', viewerHeight)
      .attr('class', 'overlay')
      .call(zoomListener)
        .on('wheel.zoom', null)
        .on('dblclick.zoom', null);
  };

  function transformData(){
    // Show nodes from the top-most two levels of the tree; nodes beneath will
    // be hidden until the user chooses to view them.
    establishMaxLabelLength.call(this);
    updateTreeData.call(this);
    recurseToggle(this.treeData);

    // Define the root
    this.root = this.treeData;
    this.root.x0 = viewerHeight / 2;
    this.root.y0 = 0;

    ETHelper.eachNode([this.root], function(node) {
      node.loads = {};
      node.loads[false] = node.load;
    });
  };

  function childCount(level, n) {
    if (n.children && n.children.length > 0) {
      if (levelWidth.length <= level + 1) levelWidth.push(0);

      levelWidth[level + 1] += n.children.length;
      n.children.forEach(function(d) {
        childCount(level + 1, d);
      });
    }
  };

  function overCapacity(d) {
    var load = (d.altLoad || d.load);
    return d.capacity && (d3.max(load) > d.capacity || d3.min(load) < -d.capacity);
  };

  function setNodeClass(data){
    var nodeClass = ("node " + data.stakeholder);
    if(data.node_selected){ nodeClass += " selected" }
    return nodeClass;
  };

  function recurseToggle(n){
    toggleChildren(n)
    if(n.children && n.children.length > 0){
      n.children.forEach(recurseToggle);
    };
  };

  function establishMaxLabelLength(){
    // Call visit function to establish maxLabelLength
    visit(this.treeData,
      function(d) {
        maxLabelLength = Math.max(d.name.length, maxLabelLength);

        if (d.children && d.children.length === 0) {
          d.children = null;
        }
      },
      function(d) {
        return d.children && d.children.length > 0 ? d.children : null;
      }
    );
  };

  function updateTreeData(){
    visit(this.treeData, toggleChildren, function(n) { return n._children });
  };

  // Shows or hides children depending on the current state.
  function toggleChildren(d) {
    if(d.children){
      d._children = d.children;
      d.children = null;
    }
    else if (d._children) {
      d.children = d._children;
      d._children = null;
    }

    return d;
  };

  function visit(parent, visitFn, childrenFn) {
    if (!parent) return;

    var children, count, i;

    visitFn(parent);
    children = childrenFn(parent);

    if (children) {
      count = children.length;

      for (i = 0; i < count; i++) {
        visit(children[i], visitFn, childrenFn);
      }
    }
  };

  // Function to center node when clicked/dropped so node doesn't get lost
  // when collapsing/moving with large amount of children.
  function centerNode(source) {
    var scale = zoomListener.scale(),
        x = source.x + 250
        y = 50;

    d3.select('g').transition()
      .duration(duration).ease(ease)
      .attr('transform', 'translate(' + x + ',' + y + ')' +
                         'scale(' + scale + ')');

    zoomListener.scale(scale);
    zoomListener.translate([x, y]);
  };

  function reloadCharts(){
    if(LoadChartHelper.forceReload){
      $(".load-graph .chart").remove();
      LoadChartHelper.forceReload = false;
    };
  };

  function addNewLoadChartPlatform(uniqueId, d){
    var loadPlatform = $("<div>").addClass(uniqueId).addClass("chart");
    loadPlatform.html('<svg></svg>');
    $(".load-graph").prepend(loadPlatform);

    if (this.strategyLoads && this.strategyShown) {
      new LoadChart([
        { values: d.altLoad, name: d.name + ' (with strategies)', color: '#95BB95', area: true },
        { values: d.load,    name: d.name, area: false, color: '#1F77B4' }
      ], d.capacity).render('.' + uniqueId + ' svg')
    } else {
      new LoadChart([
        { values: d.load, name: d.name, area: true, color: '#1F77B4' }
      ], d.capacity).render('.' + uniqueId + ' svg')
    }
  };

  // Toggle children on click.
  function click(d) {
    if (d3.event && d3.event.defaultPrevented) return; // click suppressed

    toggleSelectedNode.call(this);

    _self.lastClicked = d;
    _self.showChart(d);

    $(".nav-tabs li a[href='#load']").tab('show');
    LoadChartHelper.reloadChart(d.id);

    $('#technologies .row-fluid, p.info').hide();
    $('#technologies .row-fluid[data-node="' + d.name + '"]').show();

    enableCsvDownloadCurveButton(d);
  };

  function enableCsvDownloadCurveButton(d){
    var downloadBtn = $('#load a.download-curve')
        downloadBtn.parent().removeClass("hidden");

    downloadBtn.off('click').on('click', function(event) {
      event.preventDefault();
      CSV.download(d.load.join("\n"),
        (d.name + ' Curve.csv'), "data:text/csv;charset=utf-8");
    });
  };

  function toggleSelectedNode(){
    d3.selectAll(".overlay circle, .overlay text").style("opacity", 0.3);
    d3.selectAll(".overlay text").style({
      "font-weight":     "normal",
      "text-decoration": "none"
    });

    d3.select(this).select("circle").style("opacity", 1.0);
    d3.select(this).select("text").style({
      "opacity":         1.0,
      "font-weight":     "bold"
    });
  };

  function dblClick(d) {
    if (d3.event.defaultPrevented) return; // click suppressed

    if (d._children || d.children) {
      toggleChildren(d);
      _self.update(d);
      centerNode(d);
    }
  };

  function resetStyle(){
    if(d3.event.target.className.baseVal == "overlay"){
      d3.selectAll(".overlay circle, .overlay text").style("opacity", 1.0);
      d3.selectAll(".overlay text").style({
        "font-weight": "normal"
      });
    };
  };

  function createD3Tree(){
    var tree = d3.layout.tree().nodeSize([nodeSize, nodeSize]);

    return tree.sort(function(a, b) {
      return b.name.toLowerCase() < a.name.toLowerCase() ? 1 : -1;
    });
  };

  function createD3Diagonal(){
    return d3.svg.diagonal().projection(function(d) {
      return [d.x, d.y];
    });
  };

  // Define the zoomListener which calls the zoom function on the "zoom"
  // event constrained within the scaleExtents
  function createZoomListener(){
    return d3.behavior.zoom()
      .scaleExtent([0.1, 3]).on('zoom', function(){
        svgGroup.attr('transform',
          'translate(' + d3.event.translate + ')' +
          'scale(' + d3.event.scale + ')');
      });
  };

  // Listener which prevents the drag movement of the diagram when clicking on
  // a node.
  function createDragListener(){
    return d3.behavior.drag().on('dragstart', function(d) {
      d3.event.sourceEvent.stopPropagation();
    });
  };

  function TreeGraph(_url, _treeData, _container){
    this.url      = _url;
    this.treeData = _treeData;
    container     = _container;

    tree          = createD3Tree();
    diagonal      = createD3Diagonal();
    zoomListener  = createZoomListener();
    dragListener  = createDragListener();
  };

  return TreeGraph;
})();
