FactoryGirl.define do
  factory :topology do
    name "Topology"
    graph { YAML.load(<<-YML.strip_heredoc) }
      ---
      name: :hv
      children:
      - name: :mv
        children:
        - name: :lv1
        - name: :lv2
    YML
  end

  factory :topology_with_capacity, class: Topology do
    name "Topology"
    graph { YAML.load(<<-YML.strip_heredoc) }
      ---
      name: :hv
      capacity: 1
      children:
      - name: :mv
        capacity: 1
        children:
        - name: :lv1
          capacity: 1
          units: 1
        - name: :lv2
          capacity: 1
          units: 1
    YML
  end

  factory :topology_caching, class: Topology do
    name "Topology"
    graph { YAML.load(<<-YML.strip_heredoc) }
      ---
      name: :hv
      load:
        - 3
      children:
      - name: :mv
        load:
          - 2
        children:
        - name: :lv1
          load:
            - 1
        - name: :lv2
          load:
            - 4
    YML
  end

  factory :large_topology, class: Topology do
    name "Large Topology"
    graph { YAML.load(<<-YML.strip_heredoc) }
      ---
      name: :hv
      children:
      - name: :mv
        children:
        - name: :lv1
        - name: :lv2
        - name: :lv3
        - name: :lv4
    YML
  end

  factory :topology_with_stakeholders, class: Topology do
    name "Topology stakeholders"
    graph { YAML.load(<<-YML.strip_heredoc) }
      ---
      name: hv
      stakeholder: system operator
      children:
      - name: mv
        children:
        - name: lv1
          stakeholder: customer
        - name: lv2
          stakeholder: customer
    YML
  end

  factory :topology_with_financial_information, class: Topology do
    name "Topology finances"
    graph { YAML.load(<<-YML.strip_heredoc) }
      ---
      name: hv
      children:
      - name: mv
        capacity: 16000
        technical_lifetime: 30
        investment_cost: 150000
        stakeholder: system operator
        children:
        - name: 'lv1'
          capacity: 500
          technical_lifetime: 30
          yearly_o_and_m_costs: 1000
          investment_cost: 50000
          stakeholder: system operator
        - name: 'lv2'
          capacity: 700
          economic_lifetime: 30
          investment_cost: 50000
          stakeholder: system operator
          children:
          - name: 'hh1'
            stakeholder: customer
            capacity: 17.25
          - name: Households in coop
            stakeholder: cooperation
            capacity: 17.25
            units: 10
        - name: 'lv3'
          capacity: 500
          technical_lifetime: 30
          investment_cost: 50000
          stakeholder: system operator
    YML
  end
end
