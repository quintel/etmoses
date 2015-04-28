# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'etloader'
set :repo_url, 'https://github.com/quintel/etloader.git'

set :rbenv_type, :user
set :rbenv_ruby, '2.1.1'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}

set :linked_files, %w{config/database.yml config/email.yml config/secrets.yml}

set :linked_dirs, %w{
  bin log tmp/pids tmp/cache tmp/sockets vendor/bundle
  public/system data/curves
}

namespace :deploy do
  desc 'Restart application'
  task :restart do
    invoke 'unicorn:restart'
  end

  after 'deploy:compile_assets', 'paperclip:build_missing_styles'
  after :publishing, :restart
end
