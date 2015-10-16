var TopologyPreviewer = (function(){
  var topologyGraph, presetData, style, svgGroup, data, root, tree, svgHeight, svgWidth,
      currentStylesheet;

  var nodeIds         = 0,
      maxLabelLength  = 20,
      duration        = 250,
      depthCounter    = 0,
      endPointCounter = 0,
      stepSize        = 20,
      ease            = 'cubic-out';

  var stylesheet = {
    full: {
      renderLabels: true,
      lineSpace: 280,
      margin: { left: 100, top: 15 }
    },
    simple: {
      renderLabels: false,
      lineSpace: 60,
      margin: { left: 20, top: 15 }
    }
  };

  var diagonal = d3.svg.diagonal()
      .projection(function(d) { return [d.x, d.y]; });

  TopologyPreviewer.prototype = {
    preview: function(){
      clear();

      currentStylesheet = stylesheet[style];
      svgHeight         = viewerHeight() + 100;
      svgWidth          = viewerWidth();
      svg               = buildBaseSvg();
      data              = [presetData];
      root              = data[0];

      svgGroup = svg.append('g');
      svgGroup.attr('transform', function(d){
        return "translate(" + currentStylesheet.margin.left + "," + currentStylesheet.margin.top + ")";
      });

      tree = d3.layout.tree().size([
        svgHeight - currentStylesheet.margin.top + 5, svgWidth + 50
      ]);
      updateTree(root)
    }
  };

  function clear(){
    $(topologyGraph).find("svg").remove();
  };

  function updateTree(source){
    var nodes = tree.nodes(root).reverse(),
        links = tree.links(nodes);

    tree.separation(function(a,b){
      return (a.parent == b.parent ? 1 : 2) / a.depth;
    });

    nodes.forEach(function(d) { d.y = d.depth * currentStylesheet.lineSpace; });

    var node = svgGroup.selectAll("g.node")
      .data(nodes, function(d) { return d.id || (d.id = ++nodeIds); });

    var nodeEnter = node.enter().append("g")
      .attr("class", "node")
      .attr("transform", function(d) {
        return "translate(" + d.x + "," + d.y + ")";
      })
      .classed('collapsed', function(d) {
        return d._children;
      });

   nodeEnter.append("circle")
     .attr("r", 8)
     .style("fill", "#fff");

   if(currentStylesheet.renderLabels){
     nodeEnter.append("text")
       .attr("x", function(d) {
         return d.children || d._children ? -13 : 13; })
       .attr("dy", ".35em")
       .attr("text-anchor", function(d) {
         return d.children || d._children ? "end" : "start"; })
       .text(function(d) { return d.name; })
       .style("fill-opacity", 1);
   };

   var link = svgGroup.selectAll("path.link")
       .data(links, function(d) { return d.target.id; });

   link.enter().insert("path", "g")
     .attr("class", "link")
     .attr("d", diagonal);
  };

  function buildBaseSvg(){
    return d3.select(topologyGraph).append('svg')
      .attr('width', svgWidth)
      .attr('height', svgHeight)
      .attr('class', 'overlay')
      .call(zoomListener)
        .on('wheel.zoom', null)
        .on('dblclick.zoom', null);
  };

  function dragListener(){};

  function zoomListener(){};

  function viewerWidth(){
    endPointCounter = 1;
    var totalWidth = (endPointCount(presetData) * stepSize);
    return totalWidth;
  };

  function viewerHeight(){
    depthCounter = 1;
    var totalHeight = (depthCount(presetData) * currentStylesheet.lineSpace);
    return totalHeight + currentStylesheet.margin.top;
  };

  function depthCount(d){
    if(d.children){
      for(var i = 0; i < d.children.length; i++){
        depthCount(d.children[i]);
        if(d.children[i].children){
          depthCounter++;
          break;
        }
      };
    };
    return depthCounter;
  };

  function endPointCount(d){
    for(var i = 0; i < d.children.length; i++){
      d.children[i].children ? endPointCount(d.children[i]) : endPointCounter++;
    };
    return endPointCounter;
  };

  function TopologyPreviewer(_topologyGraph, _presetData, _style){
    topologyGraph = _topologyGraph;
    presetData    = _presetData ? _presetData.graph : JSON.parse($(topologyGraph).find(".data").text());
    style         = _style || "full";
  };

  return TopologyPreviewer;
})();

$(document).on("page:change", function(){
  if($("div.topology-graph").length > 0){
    new TopologyPreviewer(".topology-graph").preview();
  }
});
