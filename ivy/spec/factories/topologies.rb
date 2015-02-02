FactoryGirl.define do
  factory :topology do
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
end
