$(document).on "page:change", ->
  if (container = $('.topology-graph')).length
    $('.topology-graph').empty().append('<svg></svg>')
