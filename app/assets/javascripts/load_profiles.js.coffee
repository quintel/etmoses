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

  $('#load_profile_load_profile_category_id').on 'change', ->
    loadCurveFields = []
    value = $(this).val()
    option_data = $(this).find("option[value='"+value+"']")
    for i in [0...option_data.data('numberOfRows')]
      loadCurveFields.push($(".load-curve-file-field").clone())

    $(".load-curve-wrapper").empty()

    for loadCurveField in loadCurveFields
    	$(".load-curve-wrapper").append(loadCurveField)

  if (container = $('.profile-graph')).length
    $.getJSON(container.data('url')).success (profile) ->
      $('.profile-graph').empty().append('<svg></svg>')

      new (window.LoadChart)([{
        values: profile.values, name: profile.name || profile.key, area: true
      }]).render('.profile-graph svg')
