$(document).on 'page:change', ->
  $('form .load-curve').each (i, target)->
    $(this).filestyle(buttonBefore: true, buttonText: $(target).data("buttonName"))

  $('form #financial_profile_curve').filestyle(buttonBefore: true)
  $('#testing_ground_technology_profile_csv').filestyle(buttonBefore: true)

