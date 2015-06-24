calculateConcurrency = ()->
  $.ajax
    url: '/testing_grounds/calculate_concurrency'
    type: "POST"
    dataType: "script"
    data:
      technology_distribution: technology_distribution()

technology_distribution = ->
  tech_distribution = JSON.parse($("textarea#technology_distribution").text())
  for tech in tech_distribution
    concurrency = $(".check_box input[name='" + tech.type + "']:checked").val();
    tech.concurrency = concurrency

  tech_distribution_json = JSON.stringify(tech_distribution)
  $("textarea#technology_distribution").text(tech_distribution_json)
  tech_distribution_json

$(document).on "page:change", ->
  if $("#new_testing_ground, .edit_testing_ground").length > 0
    $(".toggle-concurrency").click ->
      if $(this).hasClass("edit") && confirm("Are you sure? Changing concurrency might cause unwanted changes")
        calculateConcurrency()
      else
        calculateConcurrency()

    $(".toggle-whitelist").click ->
      $(".check_box input").not(":checked").prop("checked", true)
