var TopologyPreviewer = (function(){
  var topologyGraph, svgGroup, data, root, tree, svgHeight, svgWidth;

  var nodeIds         = 0,
      maxLabelLength  = 20,
      duration        = 250,
      endPointCounter = 0,
      stepSize        = 20,
      ease            = 'cubic-out';

  var diagonal = d3.svg.diagonal()
      .projection(function(d) { return [d.y, d.x]; });

  TopologyPreviewer.prototype = {
    preview: function(){
      svgHeight = viewerHeight();
      svgWidth  = viewerWidth();
      svg       = buildBaseSvg();
      data      = [graphData()];
      root      = data[0];

      svgGroup = svg.append('g');
      svgGroup.attr('transform', function(d){
        return "translate(" + 100 + "," + 0 + ")";
      });

      tree = d3.layout.tree().size([svgHeight, svgWidth])
      updateTree(root)
    }
  };

  function updateTree(source){
    var nodes = tree.nodes(root).reverse(),
        links = tree.links(nodes);

    nodes.forEach(function(d) { d.y = d.depth * 180; });

    var node = svgGroup.selectAll("g.node")
      .data(nodes, function(d) { return d.id || (d.id = ++nodeIds); });

    node.classed('collapsed', function(d) { return d._children; });

    var nodeEnter = node.enter().append("g")
      .attr("class", "node")
      .attr("transform", function(d) {
        return "translate(" + d.y + "," + d.x + ")";
      })
      .classed('collapsed', function(d) {
        return d._children;
      });

    nodeEnter.append("circle")
      .attr("r", 8)
      .style("fill", "#fff");

    nodeEnter.append("text")
      .attr("x", function(d) {
        return d.children || d._children ? -13 : 13; })
      .attr("dy", ".35em")
      .attr("text-anchor", function(d) {
        return d.children || d._children ? "end" : "start"; })
      .text(function(d) { return d.name; })
      .style("fill-opacity", 1);

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

  function graphData(){
    return JSON.parse($(topologyGraph).find(".data").text());
  };

  function viewerWidth(){
    return $(topologyGraph).width();
  };

  function viewerHeight(){
    endPointCounter = 0;
    var totalHeight = (endPointCount(graphData()) * stepSize);
    return totalHeight;
  };

  function endPointCount(d){
    for(var i = 0; i < d.children.length; i++){
      d.children[i].children ? endPointCount(d.children[i]) : endPointCounter++;
    };
    return endPointCounter;
  };

  function TopologyPreviewer(_topologyGraph){
    topologyGraph = _topologyGraph;
  };

  return TopologyPreviewer;
})();

$(document).on("page:change", function(){
  if($(".topology-graph").length > 0){
    new TopologyPreviewer(".topology-graph").preview();
  }
});
