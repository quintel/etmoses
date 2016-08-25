require 'delayed-plugins-airbrake'

Delayed::Worker.delay_jobs = !Rails.env.test?
Delayed::Worker.max_attempts = 3
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'))
Delayed::Worker.plugins << Delayed::Plugins::Airbrake::Plugin
