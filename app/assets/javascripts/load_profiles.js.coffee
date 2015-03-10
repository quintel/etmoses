# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  if (container = $('.profile-graph')).length
    $.getJSON(container.data('url')).success (profile) ->
      $('.profile-graph').empty().append('<svg></svg>')

      new (window.LoadChart)([{
        key:    profile.name || profile.key
        area:   true
        values: window.downsampleCurve(profile.values, 365)
      }]).render('.profile-graph svg')
