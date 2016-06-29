module ApplicationHelper
  def tooltip_tag(tooltip_text)
    link_to "#", data: {toggle: 'tooltip', placement: 'right', trigger: 'click'}, title: tooltip_text, class: "tooltip-link" do
      content_tag(:span, nil, class: "glyphicon glyphicon-info-sign")
    end
  end

  def default_values(object)
    Hash[%w(capacity volume demand).map do |default|
      [default, object.defaults[default]]
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


  # Public: Sorts given technologies into a hash by the carrier for use in a
  # grouped select. Yields each technology; the block should return an array
  # with the name and key of the technology.
  #
  # For example
  #
  #   carrier_grouped_technologies(techs) do |tech|
  #     [I18n.t("inputs.#{ tech.key }", tech.key]
  #   end
  #
  # Returns a Hash{String => Array[Technology]}.
  def carrier_grouped_technologies(techs)
    techs.group_by(&:carrier).each_with_object({}) do |(key, techs), data|
      data[I18n.t("carriers.#{ key }")] =
        techs.map { |t| yield(t) }.sort_by(&:first)
    end
  end
end
