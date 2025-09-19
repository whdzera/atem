require 'discordrb'
require 'dotenv'
require 'logger'
Dir[File.join(__dir__, 'controllers/*.rb')].sort.each do |file|
  require_relative file
end

Dotenv.load(File.expand_path('../config/.env', __dir__))

TOKEN = ENV['token_discord']
SERVER_ID = ENV['server_id_discord']
CLIENT_ID = ENV['client_id_discord']
logger = Logger.new($stdout)
logger.level = Logger::INFO

begin
  logger.info "[#{Time.now}] Starting Discord Bot..."
  
  bot = Discordrb::Bot.new(
    token: TOKEN,
    client_id: CLIENT_ID,
    intents: %i[server_messages server_members],
    compress_mode: :large
  )

  # Register global slash commands (add 'server_id: SERVER_ID' for development)
  bot.register_application_command(:hello, 'Get a greeting message')
  bot.register_application_command(:start, 'Start using the bot')
  bot.register_application_command(:ping, 'Check bot latency')

  # Bot ready event
  bot.ready do |_event|
    bot.game = 'Bot'
    logger.info "[#{Process.pid} #{Time.now}] Running Bot - Discord"
  end

  # /start command
  bot.application_command(:start) do |event|
    event.respond(content: "Welcome to HelloBot! Use /hello to get a greeting.")
  end

  # /hello command
  bot.application_command(:hello) do |event|
    response = Hello.say
    event.respond(content: response)
    logger.info "Command used by #{event.user.username}: /hello"
  end

  # /Ping command
  bot.application_command(:ping) do |event|
    start_time = Time.now
    event.defer

    latency = Ping.calculate_latency(start_time)
    
    event.edit_response(content: Ping.with_latency(latency))
  rescue StandardError => e
    event.respond(content: "Error calculating ping: #{e.message}")
  end

  bot.run

rescue StandardError => e
  logger.error "[Unhandled Error] #{e.class}: #{e.message}"
  logger.error e.backtrace.join("\n")
  sleep 5
  retry
end