# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on "page:change", ->
  $("li.category").on("click", (e)->
    $(e.currentTarget).children("ul").slideToggle(200)
  )

  $("li.category").children().on("click", (e)->
    e.stopPropagation()
  )

  if (container = $('.profile-graph')).length
    $(".profile-graph").each ->
      self = this
      $(this).empty().append('<svg></svg>')
      render_class = ("." + $(this).attr("class").replace(/\s/g, '.') + " svg")

      $.getJSON($(this).data('url')).success (profile) ->
        new (window.LoadChart)([{
          values: profile.values, name: profile.name || profile.key, area: true }],
          null,
          $(self).data('curveType')
        ).render(render_class)
