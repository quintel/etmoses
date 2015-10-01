var ProfileSelectBoxes = (function(){
  var etmDefaults, edsnSwitch;
  var isChanged = false;
  var defaultValues = { defaultCapacity: null, defaultDemand: null, defaultVolume: null };
  var attributes = {
    technical_lifetime:                  null,
    initial_investment:                  null,
    full_load_hours:                     null,
    om_costs_per_year:                   null,
    om_costs_per_full_load_hour:         null,
    om_costs_for_ccs_per_full_load_hour: null
  };

  ProfileSelectBoxes.prototype = {
    add: function(){
      addProfileSelectBoxes();
      addChangeListenerToNameBox();
      addChangeListenerToProfileBox();
    },

    update: function(){
      updateSelectBoxes();
    }
  };

  function updateSelectBoxes(){
    $("select.name").each(function(){
      $(this).parent().next().find("select").val($(this).data('profile'));
    });
  };

  function addProfileSelectBoxes(){
    $("select.name").each(function(){
      cloneAndAppendProfileSelect.call(this);
    });
  };

  function addChangeListenerToNameBox(){
    $("select.name").off("change").on("change", function(){
      isChanged = true;

      fetchEtmAttributes.call(this);
      cloneAndAppendProfileSelect.call(this);
    });
  };

  function fetchEtmAttributes(){
    if(/^(base_load|generic)/.test($(this).val())){
      setEtmAttributes.call(this, attributes);
      return false;
    };

    $.ajax({
      type: "POST",
      url: $("#profiles-table").data("fetchUrl"),
      data: { key: $(this).val() },
      success: setEtmAttributes.bind(this)
    });
  };

  function setEtmAttributes(data){
    for(var key in attributes){
      $(this).parents("tr").find("." + key + " input").val(data[key]);
    };
  };

  function addChangeListenerToProfileBox(){
    $("td.profile select").off().on("change", function(){
      updateTextCells(this, $(this).parents("tr"));
    });
  };

  function cloneAndAppendProfileSelect(){
    if(edsnSwitch.isEdsn.call(this)){
      edsnSwitch.cloneAndAppendProfileSelect.call(this);
    }
    else{
      defaultCloneAndAppend.call(this);
    }
  };

  function defaultCloneAndAppend(){
    var technology = $(this).val();
    var profileSelectbox = $(".hidden.profile select." + technology).clone(true, true);

    $(this).parents("tr").find(".units input").off("change");
    $(this).parent().next().html(profileSelectbox);

    updateTextCells.call(this, profileSelectbox);

    if(!isChanged){
      profileSelectbox.val($(this).data('profile'));
    };
  };

  function updateTextCells(profileSelectbox){
    var technologyDefaults = getDefaults.call(this);
    var profileDefaults = getDefaults.call(profileSelectbox);

    var key;

    for(var defaultValue in defaultValues){
      key = defaultValue.replace(/default/, '').toLowerCase();

      if (key === 'capacity') {
        key = 'electrical_capacity';
      }

      setCellDefault.call({
        techBox:        this,
        key:            key,
        techDefault:    technologyDefaults[defaultValue],
        profileDefault: profileDefaults[defaultValue]
      });
    };
  };

  function getDefaults(){
    var selectedOption = $(this).find("option[value='" + $(this).val() + "']");

    return selectedOption.data() || defaultValues;
  };

  function setCellDefault(){
    var inputField = $(this.techBox).parents("tr").find('.' + this.key + " input");
    var technology = $(this.techBox).val();
    var etmValue   = defaultsFromEtm(technology)[this.key];
    var userInput  = parseFloat(inputField.val());

    if(etmValue == userInput || isChanged) userInput = undefined;

    inputField.val(userInput || etmValue ||
      this.profileDefault || this.techDefault || '');
  };

  function defaultsFromEtm(tech){
    return etmDefaults[tech] ? etmDefaults[tech][0] : {};
  };

  function setEtmDefaults(){
    var profile = JSON.parse($("#testing_ground_technology_profile").text());
    var technologies = []

    Object.keys(profile).map(function(key){
      technologies = technologies.concat(profile[key])
    });

    return ETHelper.groupBy(technologies, 'type');
  };

  function ProfileSelectBoxes(_edsnSwitch){
    etmDefaults = setEtmDefaults();
    edsnSwitch = _edsnSwitch;
  };

  return ProfileSelectBoxes;
})();
