FactoryGirl.define do
  factory :testing_ground do
    name 'My Testing Ground'

    topology

    technologies { YAML.load(<<-YML.strip_heredoc) }
      ---
      - name: One
        load: 1.2
      - name: Two
        load: -0.3
      - name: Three
        load: 3.2
      - name: Four
        load: 0.1
    YML

    technology_profile { YAML.load(<<-YML.strip_heredoc) }
      ---
      lv1:
      - name: One
        load: 1.2
      - name: Two
        load: -0.3
      lv2:
      - name: Three
        load: 3.2
      - name: Four
        load: 0.1
    YML
  end
end
