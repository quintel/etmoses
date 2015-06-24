module ApplicationHelper
  def tooltip_tag(tooltip_text)
    link_to "#", data: {toggle: 'tooltip', placement: 'right'}, title: tooltip_text, class: "tooltip-link" do
      content_tag(:span, nil, class: "glyphicon glyphicon-info-sign")
    end
  end
end
