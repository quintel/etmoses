module ApplicationHelper
  def tooltip_tag(tooltip_text)
    link_to "#", data: {toggle: 'tooltip', placement: 'right'}, title: tooltip_text, class: "tooltip-link" do
      content_tag(:span, nil, class: "glyphicon glyphicon-info-sign")
    end
  end

  def default_values(object)
    Hash[%i(default_capacity default_volume default_demand).map do |default|
      [default, object.send(default)]
    end]
  end
end
