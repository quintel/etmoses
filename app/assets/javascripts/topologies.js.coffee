showTopology = (url, element) ->
  [width, height] = [1000, 400]

  d3.json url, (error, json) ->
    $('.loading', element).detach()

    tree     = d3.layout.tree().size([width, height - 40])
    diagonal = d3.svg.diagonal().projection((d) -> [d.x, d.y])
    root     = json.graph[0]

    # Stop the top level from being too far separated from each other, leading
    # to very wide diagrams.
    tree.separation (a, b) ->
      if a.parent is root and b.parent is root then 2 else 1

    svg = d3.select(element)
      .append('svg')
        .attr('width', width)
        .attr('height', height)
      .append('g')
        .attr("transform", "translate(0,5)")

    nodes = tree.nodes(json.graph[0])
    links = tree.links(nodes)

    # Draw links.

    link = svg
      .selectAll('path.link')
        .data(links)
      .enter().append('path')
        .attr('class', 'link')
        .attr('d', diagonal)

    # Draw nodes.

    node = svg
      .selectAll('g.node')
      .data(nodes)
      .enter().append('g')
      .attr('class', 'node')
      .attr('transform', (data) -> "translate(#{ data.x }, #{ data.y })")

    # Draw a rectangle around each node.

    node.append('rect')
      .attr('width', 120).attr('height', 25)
      .attr('rx', 5).attr('ry', 5) # Rounded corners
      .attr('x', -60).attr('y')    # Relative x/y coords

    # Add labels.

    node.append('text')
      .attr('dx', 0).attr('dy', 17) # Relative x/y coords.
      .attr('text-anchor', 'middle')
      .text((data) -> data.name)

$(document).on "page:change", ->
  $('.topology-view').each (idx, viewEl) ->
    showTopology($(viewEl).data('url'), viewEl)
