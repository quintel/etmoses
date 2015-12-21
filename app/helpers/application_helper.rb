module ApplicationHelper
  def tooltip_tag(tooltip_text)
    link_to "#", data: {toggle: 'tooltip', placement: 'right', trigger: 'click'}, title: tooltip_text, class: "tooltip-link" do
      content_tag(:span, nil, class: "glyphicon glyphicon-info-sign")
    end
  end

  def default_values(object)
    Hash[%i(default_capacity default_volume default_demand).map do |default|
      [default, object.send(default)]
    end]
  end

  def stringify_values(hash)
    Hash[hash.map do |k, v|
      [k, v.to_s]
    end]
  end

  def recent_testing_grounds
    policy_scope(TestingGround).latest_first.select(:id, :name).limit(5)
  end
end
