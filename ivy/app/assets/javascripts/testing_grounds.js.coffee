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

    if error
      errData = JSON.parse(error.responseText)
      errEl   = $('<div class="error"></div>')

      errEl.append($('<span class="message"></span>').text(errData['error']))

      if errData.hasOwnProperty('message')
        errEl.append($('<pre class="detail"></pre>').text(errData['message']))

      if errData.hasOwnProperty('backtrace')
        errEl.append($('<pre class="backtrace"></pre>').html(errData['backtrace'].join('<br>')))

      $(element).append(errEl)

      return false

    tree     = d3.layout.tree().size([width, height - 40])
    diagonal = d3.svg.diagonal().projection((d) -> [d.x, d.y])
    root     = json.graph

    # Stop the top level from being too far separated from each other, leading
    # to very wide diagrams.
    tree.separation (a, b) -> 1

    svg = d3.select(element)
      .append('svg')
        .attr('width', width)
        .attr('height', height)
      .append('g')
        .attr("transform", "translate(0,5)")

    nodes = tree.nodes(root)
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

    point = parseInt($('.point-changer input[name=point]').val(), 10) or 0

    node.append('text')
      .attr('dx', 0).attr('dy', 17) # Relative x/y coords.
      .attr('text-anchor', 'middle')
      .text((data) ->
        if data.load?[point]
          "#{ data.name } (#{ data.load[point] })"
        else
          data.name
      )

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
  $('.testing-ground-view').each (idx, viewEl) ->
    if $('.loading', viewEl).length
      svg = showTopology($(viewEl).data('url'), viewEl)

      $('#technologies .technology').hover(
        ((event) -> highlightNode(viewEl, $(event.currentTarget).data('node'))),
        ((event) -> highlightNone(viewEl))
      )

  # Set up the network editors.

  for selector in ['textarea#testing_ground_topology_attributes_graph', 'textarea#testing_ground_technologies']
    textarea = $(selector)

    if textarea.length and ! textarea.data('editor')
      createEditor(textarea)
