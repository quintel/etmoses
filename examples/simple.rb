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
      - name: 'Heat Pump #1'
        efficiency: 4.0
        capacity: 2.5
      - name: 'Washing Machine'
        demand: 11.1
      - name: 'Computer #1'
        demand: 12.3

    "LV #2":
      - name: 'Heat Pump #2'
        efficiency: 4.0
        capacity: 2.5
      - name: 'Solar Panel #1'
        efficiency: 1.0
        capacity: 1.5
      - name: 'Computer #2'
        demand: 12.3

    "LV #3":
      - name: 'Heat Pump #3'
        efficiency: 4.5
        capacity: 3.5
      - name: 'Solar Panel #2'
        efficiency: 1.0
        capacity: 1.5
      - name: 'Toy'
        demand: 2.3
    TECHS

    ETLoader.build(topology, technologies)
  end
end
