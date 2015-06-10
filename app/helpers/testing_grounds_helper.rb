module TestingGroundsHelper
  def import_topology_select_tag(form)
    topologies = Topology.named.map do |topo|
      [(topo.name || "No name specified"), topo.id]
    end

    topologies.unshift(['- - -', '-', { disabled: true }])
    topologies.unshift(['Default topology', Topology.default.id])

    form.select(:topology_id, topologies, {}, class: 'form-control')
  end

  def link_to_etm_scenario(title, scenario_id)
    link_to(title, "http://#{ ET_MODEL_URL }/scenarios/#{ scenario_id }")
  end

  # Public: Determines if the given testing ground has enough information to
  # permit exporting back to a national scenario.
  def can_export?(testing_ground)
    testing_ground.scenario_id.present?
  end

  def profile_table_options_for_profile(technology)
    load_profiles = technology.load_profiles.map do |load_profile|
      load_profile.key
    end

    options_for_select(load_profiles)
  end

  def options_for_load_profiles
    load_profiles = LoadProfile.all.map do |load_profile|
      load_profile.key
    end

    options_for_select(load_profiles)
  end

  def profile_table_options_for_name(selected_technology)
    technologies = @technologies.map do |technology|
      [technology.name, technology.key]
    end

    options_for_select(technologies, selected: selected_technology[:type])
  end

  def node_options(profile, node)
    options_for_select(profile.keys, selected: node)
  end
end
