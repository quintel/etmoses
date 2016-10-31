FactoryGirl.define do
  factory :topology_template do
    user
    name "Test topology template"
    graph { YAML.load(<<-YML.strip_heredoc) }
      ---
      name: :hv
      children:
      - name: :mv
        children:
        - name: :lv1
          capacity: 100
        - name: :lv2
          capacity: 100
    YML
  end
end
