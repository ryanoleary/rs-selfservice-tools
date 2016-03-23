# encoding: UTF-8

namespace :prepare do
  task :bundle do
    if ENV['CI']
      sh %(bundle install --path=.bundle --jobs 1 --retry 3 --verbose)
    else
      sh %(bundle install --path .bundle)
    end
  end
end

desc 'Install required gems'
task prepare: ['prepare:bundle']

namespace :style do
  task :rubocop do
    sh %(chef exec rubocop)
  end
end

desc 'Run all style checks'
task style: ['style:rubocop']

namespace :travis do
  desc 'Run tests on Travis CI'
  task :ci do
    sh %(bundle exec rubocop)
  end
end

# The default rake task should just run it all
desc 'Install required gems'
task default: %w(prepare style)
