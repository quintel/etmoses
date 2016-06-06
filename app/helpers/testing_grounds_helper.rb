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
    link_to_etm(title, "scenarios/#{ scenario_id }")
  end

  def link_to_etm(title, link, options = {})
    link_to(title, "#{ Settings.etmodel_host }/#{ link }", target: "_blank")
  end

  # Public: Determines if the given testing ground has enough information to
  # permit exporting back to a national scenario.
  def can_export?(testing_ground)
    testing_ground.scenario_id.present?
  end

  def profile_table_options_for_name
    technologies = @technologies.sort_by(&:name).map do |technology|
      [technology.name, technology.key, data: default_values(technology).merge(
        position_relative_to_buffer: technology.default_position_relative_to_buffer,
                          composite: technology.composite,
                           includes: technology.technologies,
                            carrier: technology.carrier)
      ]
    end

    options_for_select(technologies)
  end

  def maximum_concurrency?(technology_key, profile)
    technology = profile.as_json.values.flatten.detect{|t| t[:type] == technology_key }

    technology ? (technology[:concurrency] == "max") : true
  end

  def options_for_stakeholders(stakeholder = nil)
    options = @testing_ground.topology.each_node.map do |n|
      n[:stakeholder]
    end.compact.uniq.sort

    options_for_select options.uniq, stakeholder
  end

  def options_for_testing_grounds(testing_ground)
    testing_grounds = policy_scope(TestingGround)
                        .where("`testing_grounds`.`id` != ?", testing_ground.id)
                        .joins(:business_case)
                        .order(:name)

    options_for_select(testing_grounds.map{|tg| [tg.name, tg.id] })
  end

  def options_for_strategies
    strategies = Strategies.all.map do |strategy|
      [ I18n.t("testing_grounds.strategies.#{strategy[:name]}"),
        strategy[:ajax_prop],
        { selected: !strategy[:enabled], disabled: !strategy[:enabled] } ]
    end
    options_for_select(strategies)
  end

  def default_strategies
    Hash[Strategies.all.map{|s| [s[:ajax_prop], false] }].symbolize_keys
  end

  def save_all_button(url, text = "Save all and view LES")
    link_to(text, "#", data: { url: url }, class: "btn btn-success save-all")
  end

  def composites_data
    composites = @technologies.map do |technology|
      if technology.technologies.any?
        [ technology.key, technology.technologies.map(&:key) ]
      end
    end

    Hash[composites.compact]
  end

  def concurrency_options
    Technology.for_concurrency
  end

  def composites_data
    composites = @technologies.map do |technology|
      if technology.technologies.any?
        [ technology.key, technology.technologies ]
      end
    end

    Hash[composites.compact]
  end

  def technology_class(technology)
    technology_class = technology.type
    technology_class += " buffer-child" if technology.sticks_to_composite?
    technology_class += " alert-danger" unless technology.valid?
    technology_class
  end

  def technology_data(technology, node)
    stringify_values(
      technology.attributes
        .slice(*InstalledTechnology::EDITABLES)
        .merge(node: node)
    )
  end

  def testing_ground_view_options(testing_ground)
    { id:             testing_ground.id,
      url:            data_testing_ground_url(testing_ground, format: :json),
      topology_url:   topology_url(testing_ground.topology, format: :json),
      strategies_url: update_strategies_testing_ground_url(testing_ground, format: :json)
    }
  end

  def load_date_options
    weeks = [["Whole year", 0]]

    (Date.new(2013, 1, 1)...Date.new(2013, 12, 31))
      .map{|d| d.strftime("%d %B") }
      .each_slice(7)
      .with_index do |(*a), i|
        weeks << [ "#{ a.first } - #{ a.last }" , i + 1 ]
      end

    options_for_select(weeks)
  end

  def view_as_options
    options_for_select([
      ['Total', 'total'],
      ['Stacked', 'stacked'],
      ['Individual', 'individual']
    ])
  end
end
