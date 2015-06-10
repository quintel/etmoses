calculateConcurrency = (differentiation)->
  $.ajax
    url: '/testing_grounds/calculate_concurrency'
    type: "POST"
    dataType: "script"
    data:
      technology_distribution: $("textarea#technology_distribution").text(),
      profile_differentiation: differentiation

$(document).on "page:change", ->
  if $("#new_testing_ground, .edit_testing_ground").length > 0
    $("input[name=differentiation]").change ->
      calculateConcurrency($(this).val())
