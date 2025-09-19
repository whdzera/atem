require 'rake'

task default: :help

desc 'help'
task :help do
  sh 'rake -T'
end

desc 'Run RSpec tests'
task :test do
  sh 'rspec spec/index_spec.rb'
end

desc 'Run Discord bot'
task :discord do
  sh('ruby app/discord.rb')
end

desc 'Run Telegram bot'
task :telegram do
  sh('ruby app/telegram.rb')
end
