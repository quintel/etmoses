class TestingGround::Calculator
  def initialize(testing_ground, options = {})
    @testing_ground = testing_ground
    @strategies     = options[:strategies] || {}
    @nodes          = options[:nodes]
    @resolution     = (options[:resolution] || 'low').to_sym
  end

  def calculate
    if ! Settings.cache.networks || cache.present?
      base.merge(networks: tree, tech_loads: tech_loads)
    else
      calculate_load_in_background

      @strategies.merge(pending: existing_job.present?)
    end
  end

  def network(carrier)
    fetch_networks.detect { |net| net.carrier == carrier }
  end

  private

  def tree
    TestingGround::TreeSampler.sample(networks, @resolution, @nodes)
  end

  def tech_loads
    networks.each_with_object({}) do |(carrier, network), data|
      data[carrier] = network.nodes.each_with_object({}) do |node, node_data|
        node_data[node.key] = node.get(:tech_loads)
      end
    end
  end

  def networks
    { electricity: network(:electricity),
      gas:         network(:gas) }
  end

  def calculate_load_in_background
    return if existing_job && existing_job.job

    job = @testing_ground.testing_ground_delayed_jobs.create!(job_type: job_type)
    job.update_attribute(:job, Delayed::Job.enqueue(task))
  end

  def existing_job
    @testing_ground.testing_ground_delayed_jobs.for(job_type)
  end

  def task
    TestingGroundCalculatorJob.new(@testing_ground, @strategies)
  end

  def fetch_networks
    @networks ||=
      if Settings.cache.networks
        cache.fetch(@nodes)
      else
        @testing_ground.to_calculated_graphs(@strategies)
      end
  end

  def cache
    @cache ||= NetworkCache::Cache.new(@testing_ground, @strategies)
  end

  def job_type
    SelectedStrategy.strategy_type(@strategies)
  end

  def invalid_message
    invalid_technologies = @testing_ground.invalid_technologies.map do |tech|
      "'#{tech.name}' on '#{tech.node}'"
    end

    if invalid_technologies.any?
      I18n.t("testing_grounds.error.invalid_technologies",
          invalid_technologies: invalid_technologies.join(", "))
    end
  end

  def base
    { technologies: @testing_ground.technology_profile.as_json,
      error: invalid_message }
  end
end
