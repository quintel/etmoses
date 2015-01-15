# Console --------------------------------------------------------------------

namespace :console do
  task :run do
    command = system("which pry > /dev/null 2>&1") ? 'pry' : 'irb'
    exec "#{ command } -I./lib -r./lib/etloader.rb"
  end

  desc 'Open a pry or irb session with a stub graph on `ETLoader.stub`'
  task :stub do
    command = system("which pry > /dev/null 2>&1") ? 'pry' : 'irb'
    exec "#{ command } -I./lib -r./lib/etloader.rb -r./examples/simple.rb"
  end
end

desc 'Open a pry or irb session preloaded with ETLoader'
task console: ['console:run']
