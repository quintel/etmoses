namespace :ci do
  desc <<-DESC
    Runs tasks to prepare a CI build on Semaphore.
  DESC

  task :setup do
    cp 'config/email.sample.yml',   'config/email.yml'
    cp 'config/secrets.sample.yml', 'config/secrets.yml'
    mkdir_p 'tmp/cache'
  end
end
