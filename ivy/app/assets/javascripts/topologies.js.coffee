highlightNode = (element, key) ->
  highlightNone(element)
  d3.select(element).selectAll('g.node').classed('common', (other) -> other.name is key)

  $('#technologies .technology').each (idx, element) ->
    if $(element).data('node') is key
      $(element).addClass('common')

highlightNone = (element, key) ->
  d3.select(element).selectAll('g.node').classed(common: false)
  $('#technologies .technology').removeClass('common')

showTopology = (url, element) ->
  [width, height] = [920, 400]

  d3.json url, (error, json) ->
    $('.loading', element).detach()

    tree     = d3.layout.tree().size([width, height - 40])
    diagonal = d3.svg.diagonal().projection((d) -> [d.x, d.y])
    root     = json.graph[0]

    # Stop the top level from being too far separated from each other, leading
    # to very wide diagrams.
    tree.separation (a, b) -> 1

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
      .classed('node', true)
      .attr('transform', (data) -> "translate(#{ data.x }, #{ data.y })")

    node.on('mouseover', (d) -> highlightNode(element, d.name))
    node.on('mouseout', -> highlightNone(element))

    # Draw a rectangle around each node.

    node.append('rect')
      .attr('width', 130).attr('height', 25)
      .attr('rx', 5).attr('ry', 5) # Rounded corners
      .attr('x', -65).attr('y')    # Relative x/y coords

    # Add labels.

    node.append('text')
      .attr('dx', 0).attr('dy', 17) # Relative x/y coords.
      .attr('text-anchor', 'middle')
      .text((data) -> data.name)

createEditor = (textarea) ->
  id = textarea.attr('id')

  textarea.hide()
  textarea.data('editor', true)

  textarea.after($("""
    <div class="editor-wrap"><pre id='#{ id }_editor'></pre></div>
  """))

  editor = ace.edit("#{ id }_editor")
  editor.getSession().setValue(textarea.text())
  editor.getSession().setMode('ace/mode/yaml')
  editor.setTheme('ace/theme/github')
  editor.setHighlightActiveLine(false)
  editor.setShowPrintMargin(false)

  textarea.parents('form').on 'submit', ->
    textarea.text(editor.getSession().getValue())

$(document).on "page:change", ->
  $('.topology-view').each (idx, viewEl) ->
    if $('.loading', viewEl).length
      svg = showTopology($(viewEl).data('url'), viewEl)

      $('#technologies .technology').hover(
        ((event) -> highlightNode(viewEl, $(event.currentTarget).data('node'))),
        ((event) -> highlightNone(viewEl))
      )

  # Set up the topology editors.

  for selector in ['textarea#topology_graph', 'textarea#topology_technologies']
    textarea = $(selector)

    if textarea.length and ! textarea.data('editor')
      createEditor(textarea)
