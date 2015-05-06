buildTechnologyTopology = (differentiation)->
  $.ajax
    url: '/testing_grounds/build_technology_toplogy'
    type: "POST"
    dataType: "text"
    data:
      technologies: $("textarea#testing_ground_technologies").text()
      topology: $("textarea#testing_ground_topology_attributes_graph").text()
      profile_differentiation: differentiation
    success: (data)->
      editor = ace.edit("testing_ground_technology_profile_editor")
      editor.setValue(data)
      $("textarea#testing_ground_technology_profile").text(data)

$(document).on "page:change", ->
  if $("#new_testing_ground").length > 0
    buildTechnologyTopology("min")

    $("input[name=differentiation]").change ->
      buildTechnologyTopology($(this).val())
