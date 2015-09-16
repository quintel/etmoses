module TestingGroundsHelper
  def import_topology_select_tag(form)
    topologies = Topology.named.map do |topo|
      [(topo.name || "No name specified"), topo.id]
    end

    topologies.unshift(['- - -', '-', { disabled: true }])
    topologies.unshift(['Default topology', Topology.default.id])

    form.select(:topology_id, topologies, {}, class: 'form-control')
  end

  def market_model_options
    MarketModel.all.map do |market_model|
      [market_model.name, market_model.id]
    end
  end

  def link_to_etm_scenario(title, scenario_id)
    link_to(title, "http://#{ ET_MODEL_URL }/scenarios/#{ scenario_id }", target: "_blank")
  end

  # Public: Determines if the given testing ground has enough information to
  # permit exporting back to a national scenario.
  def can_export?(testing_ground)
    testing_ground.scenario_id.present?
  end

  def profile_table_options_for_name(selected_technology)
    technologies = @technologies.visible.order(:name).map do |technology|
      [technology.name, technology.key]
    end

    options_for_select(technologies, selected: selected_key(selected_technology))
  end

  def selected_key(selected_technology)
    if selected_technology[:type] == 'base_load_edsn'
      'base_load'
    else
      selected_technology[:type]
    end
  end

  def node_options(topology, node)
    @edges ||= Topologies::EdgeNodesFinder.new(topology).find_edge_nodes

    options_for_select(@edges.map(&:key), selected: node)
  end

  def maximum_concurrency?(technology_key, profile)
    technology = profile.as_json.values.flatten.detect{|t| t[:type] == technology_key }

    technology ? (technology[:concurrency] == "max") : true
  end

  def options_for_stakeholders
    options = []

    if @testing_ground.topology
      @testing_ground.topology.each_node do |n|
        (options << n[:stakeholder] if n[:stakeholder])
      end
    end

    options_for_select options.uniq
  end

  def options_for_testing_grounds(testing_ground)
    testing_grounds = policy_scope(TestingGround)
                        .where("`testing_grounds`.`id` != ?", testing_ground.id)
                        .joins(:business_case)
                        .order(:name)

    options_for_select(testing_grounds.map{|tg| [tg.name, tg.id] })
  end

  def options_for_strategies
    options_for_select(Strategies.all.map do |strategy|
      [I18n.t("testing_grounds.strategies.#{strategy[:name]}"), strategy[:ajax_prop]]
    end)
  end

  def default_strategies
    Hash[Strategies.all.map{|s| [s[:ajax_prop], false] }].symbolize_keys
  end
end
