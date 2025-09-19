require 'telegram/bot'
require 'dotenv'
require 'logger'
Dir[File.join(__dir__, 'controllers/*.rb')].sort.each do |file|
  require_relative file
end

Dotenv.load(File.expand_path('../config/.env', __dir__))

COMMAND_PREFIX = '/'.freeze

COMMANDS = {
  start: ['/start', '/welcome', '/help'],
  hello: ['/hello'],
  ping: ['/ping'] 
}.freeze

TOKEN = ENV['token_telegram']
logger = Logger.new($stdout)
logger.level = Logger::INFO

loop do
  begin
    logger.info "[#{Time.now}] Starting Telegram Bot..."
    Telegram::Bot::Client.run(TOKEN, allowed_updates: ['message']) do |bot|
      bot.listen do |message|
        next unless message.is_a?(Telegram::Bot::Types::Message)
        next unless message.text

        text = message.text.to_s.strip
        chat_id = message.chat.id

        case
        when COMMANDS[:start].include?(text)
          bot.api.send_message(
            chat_id: chat_id,
            text: "Welcome to HelloBot! Use /hello to get a greeting.",
            parse_mode: 'Markdown'
          )
        when COMMANDS[:hello].include?(text)
          response = Hello.say
          bot.api.send_message(
            chat_id: chat_id,
            text: response,
            parse_mode: 'Markdown'
          )
        when COMMANDS[:ping].include?(text)
            start_time = Time.now
            msg = bot.api.send_message(
              chat_id: chat_id,
              text: Ping.say,
              parse_mode: 'Markdown'
            )
            latency = Ping.calculate_latency(start_time)
            bot.api.edit_message_text(
              chat_id: chat_id,
              message_id: msg.message_id,
              text: Ping.with_latency(latency),
              parse_mode: 'Markdown'
            )
        end

        logger.info "Received from @#{message.from.username}: #{message.text}"
      end
    end
  rescue Telegram::Bot::Exceptions::ResponseError => e
    logger.error "[Telegram Error] #{e.message}"
    sleep 10
  rescue StandardError => e
    logger.error "[Unhandled Error] #{e.class}: #{e.message}"
    logger.error e.backtrace.join("\n")
    sleep 5
  end
end