require 'yaml'

module ETLoader
  def self.stub
    topology = YAML.load(<<-TOPO.gsub(/^ {4}/, ''))
    ---
    - name: HV Network
      children:
      - name: MV Network
        children:
        - name: "LV #1"
        - name: "LV #2"
        - name: "LV #3"
    TOPO

    technologies = YAML.load(<<-TECHS.gsub(/^ {4}/, ''))
    ---
    "LV #1":
      - name: 'Heat Pump Type 1'
        efficiency: 4.0
        capacity: 2.5
      - name: 'Washing Machine'
        demand: 1.1
      - name: 'Computer'
        demand: 2.3

    "LV #2":
      - name: 'Heat Pump Type 1'
        efficiency: 4.0
        capacity: 2.5
      - name: 'Solar Panel'
        efficiency: 1.0
        capacity: 1.5
      - name: 'Computer'
        demand: 2.3

    "LV #3":
      - name: 'Heat Pump Type 2'
        efficiency: 4.5
        capacity: 3.5
      - name: 'Solar Panel'
        efficiency: 1.0
        capacity: 1.5
    TECHS

    ETLoader.build(topology, technologies)
  end
end
