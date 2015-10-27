calculateConcurrency = ()->
  $.ajax
    url: '/testing_grounds/calculate_concurrency'
    type: "POST"
    dataType: "script"
    data:
      technology_distribution: technology_distribution(),
      topology_id: topology_id()

topology_id = ->
  $("#testing_ground_topology_id").val()

# Also apply the concurrency settings
technology_distribution = ->
  tech_distribution = JSON.parse($("textarea#technology_distribution").text())

  for tech in tech_distribution
    concurrency = $(".check_box input[name='" + tech.type + "']")
    tech.concurrency = (if concurrency.prop('checked') then 'max' else 'min')

  tech_distribution_json = JSON.stringify(tech_distribution)
  $("textarea#technology_distribution").text(tech_distribution_json)
  tech_distribution_json

$(document).on "page:change", ->
  if $("#new_testing_ground, .edit_testing_ground").length > 0
    $(".toggle-concurrency").click (event) ->
      event.preventDefault()
      if $(this).hasClass("edit")
      	if confirm("Are you sure? Changing concurrency might cause unwanted changes")
          calculateConcurrency()
      else
        calculateConcurrency()

    $(".toggle-whitelist").click (event) ->
      event.preventDefault()
      $(this).toggleClass("all-max")
      $(".check_box input").prop("checked", !$(this).hasClass("all-max")).change()
