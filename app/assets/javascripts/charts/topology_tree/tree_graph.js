var TreeGraph = (function(){
  var url, treeData, container, root, dragListener, zoomListener, node, baseSvg,
      lastClicked, viewerWidth, tree, diagonal, svgGroup;

  var maxLabelLength  = 0,
      maxViewerHeight = 500,
      viewerHeight    = 500,
      nodeIds         = 0,
      duration        = 250,
      ease            = 'cubic-out',
      storageShown    = false,
      storageLoads    = false;

  TreeGraph.prototype = {
    showGraph: function(){
      // Define the baseSvg, attaching a class for styling and the zoomListener
      createBaseSvg();

      $('.loading').remove();
      $('#enable-storage').click(enableStorage);

      transformData();

      // Layout the tree initially and center on the root node.
      update(root);

      // Center the diagram with an offset such that *children* of the root will
      // appear to be in the center.
      centerNode(root, maxLabelLength * 10);
    }
  };

  function transformData(){
    // Show nodes from the top-most two levels of the tree; nodes beneath will
    // be hidden until the user chooses to view them.
    updateTreeData();
    toggleChildren(treeData);
    treeData.children.forEach(toggleChildren);

    // Define the root
    root = treeData;
    root.x0 = viewerHeight / 2;
    root.y0 = 0;

    ETHelper.eachNode([root], function(node) {
      node.loads = {};
      node.loads[false] = node.load;
    });
  };

  function createD3Tree(){
    var tree = d3.layout.tree().size([viewerHeight, viewerWidth]);
    return tree.sort(function(a, b) {
      return b.name.toLowerCase() < a.name.toLowerCase() ? 1 : -1;
    });
  };

  function createD3Diagonal(){
    return d3.svg.diagonal().projection(function(d) {
      return [d.y, d.x];
    });
  };

  function createBaseSvg(){
    baseSvg = d3.select(container).append('svg')
      .attr('width', viewerWidth)
      .attr('height', viewerHeight)
      .attr('class', 'overlay')
      .call(zoomListener)
        // Disable double-click causing a zoom-in.
        .on('wheel.zoom', null)
        .on('dblclick.zoom', null);

    svgGroup = baseSvg.append('g');
  };

  function createDragListener(){
    return d3.behavior.drag().on('dragstart', function(d) {
      d3.event.sourceEvent.stopPropagation();
    });
  };

  function createZoomListener(){
    // Define the zoomListener which calls the zoom function on the "zoom"
    // event constrained within the scaleExtents
    return d3.behavior.zoom()
      .scaleExtent([0.1, 3]).on('zoom', function(){
        svgGroup.attr('transform',
          'translate(' + d3.event.translate + ')' +
          'scale(' + d3.event.scale + ')');
      });
  };

  function updateTreeData(){
    // Call visit function to establish maxLabelLength
    visit(treeData, function(d) {
      maxLabelLength = Math.max(d.name.length, maxLabelLength);

      if (d.children && d.children.length === 0) {
        d.children = null;
      }
    }, function(d) {
      return d.children && d.children.length > 0 ? d.children : null;
    });

    visit(treeData, toggleChildren, function(n) { return n._children });
  };

  // Shows or hides children depending on the current state.
  function toggleChildren(d) {
    if (d.children) {
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
  function centerNode(source, xOffset) {
    xOffset = xOffset || 0;

    var height = Math.min(maxViewerHeight, viewerHeight);
    var scale = zoomListener.scale(),
    x = -source.y0 - xOffset,
    y = -source.x0;

    x = x * scale + viewerWidth  / 2;
    y = y * scale + height / 2;

    d3.select('g').transition()
    .duration(duration).ease(ease)
    .attr('transform', 'translate(' + x + ',' + y + ')' +
     'scale(' + scale + ')');

    zoomListener.scale(scale);
    zoomListener.translate([x, y]);
  };

  function showChart(d) {
    reloadCharts();

    var uniqueId = ("chart-id-" + d.id);
    var existingLoadPlatform = $(".load-graph ." + uniqueId);

    $(".load-graph .chart").hide();

    if(existingLoadPlatform.length > 0){
      existingLoadPlatform.show();
      LoadChartHelper.updateBrush(d.id);
    }
    else{
      addNewLoadChartPlatform(uniqueId, d);
    };
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

    if (storageShown && storageLoads) {
      new LoadChart([
        { values: d.load,    name: d.name + ' (with storage)', color: '#95BB95', area: true },
        { values: d.altLoad, name: d.name, area: true, color: '#1F77B4' }
      ], d.capacity).render('.' + uniqueId + ' svg')
    } else {
      new LoadChart([
        { values: d.load, name: d.name, area: true, color: '#1F77B4' }
      ], d.capacity).render('.' + uniqueId + ' svg')
    }
  };

  function update(source) {
    // Compute the new height, function counts total children of root node
    // and sets tree height accordingly. This prevents the layout looking
    // squashed when new nodes are made visible or looking sparse when nodes
    // are removed. This makes the layout more consistent.
    var levelWidth = [1],

    childCount = function(level, n) {
      if (n.children && n.children.length > 0) {
        if (levelWidth.length <= level + 1) levelWidth.push(0);

        levelWidth[level + 1] += n.children.length;
        n.children.forEach(function(d) {
          childCount(level + 1, d);
        });
      }
    },

    newHeight, nodes, links, nodeEnter, nodeUpdate, nodeExit, link;

    childCount(0, root);
    newHeight = d3.max(levelWidth) * 35; // 25 pixels per line

    // Update the SVG height to fit the contents.
    var svgDivHeight = Math.min(newHeight, maxViewerHeight);
    var baseSvgSelector = $(baseSvg[0][0]);
    baseSvgSelector.height(newHeight + 50);
    baseSvgSelector.parent().height(svgDivHeight + 50);

    tree = tree.size([newHeight, viewerWidth]);

    viewerHeight = newHeight + 50;

    // Compute the new tree layout.
    nodes = tree.nodes(root).reverse();
    links = tree.links(nodes);

    // Set widths between levels based on maxLabelLength.
    nodes.forEach(function(d) {
      d.y = (d.depth * (maxLabelLength * 10));
        // alternatively to keep a fixed scale one can set a fixed depth per
        // level. Normalize for fixed-depth by commenting out below line>
        // d.y = (d.depth * 175); //175px per level.
      });

    // Update the nodes…
    node = svgGroup.selectAll('g.node')
    .data(nodes, function(d) { return d.id || (d.id = ++nodeIds); });

    node.classed('collapsed', function(d) { return d._children; });

    // Enter any new nodes at the parent's previous position.
    nodeEnter = node.enter().append('g')
      .call(dragListener)
      .attr('class', 'node')
      .classed('collapsed', function(d) {
              // We have to run the "collapsed" function again (it is already
              // defined above), as the above version does not run the first
              // time the update() function is called.
              return d._children;
            })
      .attr('transform', function(d) {
        return 'translate(' + source.y0 + ',' + source.x0 + ')';
      })
      .on('dblclick', dblClick)
      .on('click', click);

    node.classed('exceedance', function(d) {
      return d.capacity && d3.max(d.load) > d.capacity
    });

    nodeEnter.append('circle')
    .attr('class', 'nodeCircle')
    .attr('r', 0)

    nodeEnter.append('text')
    .attr('x', function(d) { return d === root ? -10 : 10; })
    .attr('dy', '.38em')
    .attr('class', 'nodeText')
    .text(function(d) { return d.name; })
    .style('fill-opacity', 0)
    .attr('text-anchor', function(d) {
      return d === root ? 'end' : 'start';
    });

    // Update the text to reflect whether node has children or not.
    node.select('text')
    .attr('x', function(d) { return d === root ? -10 : 10; })
    .text(function(d) { return d.name; })
    .attr('text-anchor', function(d) {
      return d === root ? 'end' : 'start';
    });

    // Change the circle fill depending on whether it has children and is collapsed
    node.select('circle.nodeCircle').attr('r', 7.5);

    // Transition nodes to their new position.
    nodeUpdate = node.transition()
    .duration(duration).ease(ease)
    .attr('transform', function(d) {
      return 'translate(' + d.y + ',' + d.x + ')';
    });

    // Fade the text in
    nodeUpdate.select('text').style('fill-opacity', 1);

    // Transition exiting nodes to the parent's new position.
    nodeExit = node.exit().transition()
    .duration(duration).ease(ease)
    .attr('transform', function(d) {
      return 'translate(' + source.y + ',' + source.x + ')';
    })
    .remove();

    nodeExit.select('circle').attr('r', 0);
    nodeExit.select('text').style('fill-opacity', 0);

    // Update the links…
    link = svgGroup.selectAll('path.link')
    .data(links, function(d) {
      return d.target.id;
    });

    // Enter any new links at the parent's previous position.
    link.enter().insert('path', 'g')
    .attr('class', 'link')
    .attr('d', function(d) {
      var o = {
        x: source.x0,
        y: source.y0
      };
      return diagonal({
        source: o,
        target: o
      });
    });

    // Transition links to their new position.
    link.transition()
    .duration(duration).ease(ease)
    .attr('d', diagonal);

    // Transition exiting nodes to the parent's new position.
    link.exit().transition()
    .duration(duration).ease(ease)
    .attr('d', function(d) {
      var o = { x: source.x, y: source.y };
      return diagonal({ source: o, target: o });
    })
    .remove();

    // Stash the old positions for transition.
    nodes.forEach(function(d) {
      d.x0 = d.x;
      d.y0 = d.y;
    });
  };

  // Toggle children on click.
  function click(d) {
    if (d3.event && d3.event.defaultPrevented) return; // click suppressed

    toggleSelectedNode.call(this);
    lastClicked = d;

    // Load chart.
    var values = d.load;

    showChart(d);

    $('#technologies .row-fluid').hide();
    $('#technologies .row-fluid[data-node="' + d.name + '"]').show();

    $('.node-info .download-curve').show().unbind('click')
    .click(function(event) {
      var file = $("<a>");

      file.setAttribute('download', d.name + ' Curve.csv');
      file.setAttribute('href', 'data:text/csv;charset=utf-8,' +
       encodeURIComponent(d.load.join("\n")));
      file.click();

      event.preventDefault();
    });
  };

  function toggleSelectedNode(){
    d3.selectAll("text").style("font-weight", "normal");
    d3.selectAll("text").style("text-decoration", "none");
    d3.select(this).select("text").style("font-weight", "bold");
    d3.select(this).select("text").style("text-decoration", "underline");
  };

  function dblClick(d) {
    if (d3.event.defaultPrevented) return; // click suppressed

    if (d._children || d.children) {
      toggleChildren(d);
      update(d);
      centerNode(d);
    }
  };

  function enableStorage(event){
    event.preventDefault();

    var element = $(this);

    if (element.hasClass('disabled')) {
      return true;
    }

    if (storageShown) {
      storageShown = false;
      element.text('Enable Storage').removeClass('btn-success');
    } else {
      storageShown = true;

      if (!storageLoads || storageLoads === true) {
        element.text('Loading...').addClass('disabled');
      } else {
        element.text('Storage Enabled').addClass('btn-success');
      }
    }

    toggleStorage();
  };

  function toggleStorage() {
    if (storageShown) {
      if (storageLoads === true) {
        // Already loading...
        return false;
      } else if (storageLoads) {
        // immediately toggle storage on
        swapLoads(root);
      } else {
        storageLoads = true;

        d3.json(url + '?storage=1', function(error, offData) {
          // fetch then toggle on
          storageLoads = {};

          ETHelper.eachNode([offData.graph], function(node) {
            storageLoads[node.name] = node.load;
          });

          ETHelper.eachNode([treeData], function(node) {
            node.altLoad = storageLoads[node.name];
          });

          $('#enable-storage')
            .text('Storage Enabled')
            .addClass('btn-success')
            .removeClass('disabled');

          swapLoads(root);
        });
      }
    } else {
      swapLoads(root);
    }
  };

  function swapLoads(root) {
    ETHelper.eachNode([root], function(node) {
      var otherLoad = node.altLoad;

      node.altLoad = node.load;
      node.load    = otherLoad;
    });

    LoadChartHelper.forceReload = true

    showChart(lastClicked);
    update(root);
  };

  function TreeGraph(_url, _treeData, _container){
    url         = _url;
    treeData    = _treeData;
    container   = _container;
    viewerWidth = $(container).width();
    tree        = createD3Tree();
    diagonal    = createD3Diagonal();

    // Define the zoomListener which calls the zoom function on the "zoom"
    // event constrained within the scaleExtents
    zoomListener = createZoomListener();

    // Listener which prevents the drag movement of the diagram when clicking on
    // a node.
    dragListener = createDragListener();
  };

  return TreeGraph;
})();
