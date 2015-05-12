buildTechnologyTopology = (differentiation)->
  $.ajax
    url: '/testing_grounds/calculate_concurrency'
    type: "POST"
    dataType: "json"
    data:
      profile: $("textarea#testing_ground_technology_profile").text()
      profile_differentiation: differentiation
    success: (data)->
      console.log(data)

$(document).on "page:change", ->
  if $("#new_testing_ground, .edit_testing_ground").length > 0
    buildTechnologyTopology($("input[name=differentiation]").val())

    $("input[name=differentiation]").change ->
      buildTechnologyTopology($(this).val())
