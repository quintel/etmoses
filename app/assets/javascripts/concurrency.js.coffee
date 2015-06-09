calculateConcurrency = (differentiation)->
  $.ajax
    url: '/testing_grounds/calculate_concurrency'
    type: "POST"
    dataType: "script"
    data:
      profile: $("textarea#testing_ground_technology_profile").text(),
      topology: $("textarea#topology_graph").text(),
      profile_differentiation: (differentiation == "max")

$(document).on "page:change", ->
  if $("#new_testing_ground, .edit_testing_ground").length > 0
    $("input[name=differentiation]").change ->
      calculateConcurrency($(this).val())
