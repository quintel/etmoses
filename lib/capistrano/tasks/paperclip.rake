namespace :paperclip do
  desc "Build missing Paperclip attachment styles"
  task :build_missing_styles do
    on roles(:app) do
      within current_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, 'exec rake', 'paperclip:refresh:missing_styles'
        end
      end
    end
  end
end
