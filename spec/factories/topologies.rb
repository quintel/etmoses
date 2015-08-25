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
      name: HV Network
      children:
      - name: HS-MS Trafo
        capacity: 16000
        economic_lifetime: 30
        investment_cost: 150000
        yearly_o_and_m_cost: 10000
        stakeholder: system operator
        children:
        - name: 'MV-LS trafo #1'
          capacity: 500
          economic_lifetime: 30
          investment_cost: 50000
          yearly_o_and_m_cost: 1000
          stakeholder: system operator
        - name: 'MV-LS trafo #2'
          capacity: 700
          economic_lifetime: 30
          investment_cost: 50000
          yearly_o_and_m_cost: 1000
          stakeholder: system operator
          children:
          - name: 'Household #1'
            stakeholder: customer
            capacity: 17.25
          - name: Households in coop
            stakeholder: cooperation
            capacity: 17.25
            units: 10
        - name: 'MV-LS trafo #3'
          capacity: 500
          economic_lifetime: 30
          investment_cost: 50000
          yearly_o_and_m_cost: 1000
          stakeholder: system operator
    YML
  end
end
