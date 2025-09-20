require 'telegram/bot'
require 'dotenv'
require 'logger'
Dotenv.load(File.expand_path('../config/.env', __dir__))
Dir[File.join(__dir__, 'controllers/*.rb')].sort.each do |file|
  require_relative file
end

COMMAND_PREFIX = '/'.freeze

COMMANDS = {
  start: ['/start'],
  info: ['/info'],
  help: ['/help'],
  ping: ['/ping'],
  random: ['/random']
}.freeze

TOKEN = ENV.fetch('token_telegram')
logger = Logger.new($stdout)
logger.level = Logger::INFO

loop do
  logger.info "[#{Time.now}] Starting Telegram Bot..."
  Telegram::Bot::Client.run(TOKEN, allowed_updates: ['message']) do |bot|
    bot.listen do |message|
      next unless message.is_a?(Telegram::Bot::Types::Message)
      next unless message.text

      text = message.text.to_s.strip
      chat_id = message.chat.id

      if COMMANDS[:start].include?(text)
        bot.api.send_message(
          chat_id: chat_id,
          text: 'Welcome to Atem bot! Use /help for usage.',
          parse_mode: 'Markdown'
        )
      elsif COMMANDS[:info].include?(text)
        response = General.info
        bot.api.send_message(
          chat_id: chat_id,
          text: response,
          parse_mode: 'Markdown'
        )
      elsif COMMANDS[:help].include?(text)
        response = General.help
        bot.api.send_message(
          chat_id: chat_id,
          text: response,
          parse_mode: 'Markdown'
        )
      elsif COMMANDS[:ping].include?(text)
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
      elsif COMMANDS[:random].include?(text)

        card_data = Random.card
        card_name    = card_data['name']
        link         = card_data['card_url']
        ban_ocg      = card_data['ban_ocg'] || '-'
        ban_tcg      = card_data['ban_tcg'] || '-'
        suffix       = card_data['suffix'] || ''
        type         = card_data['type'] || '-'
        race         = card_data['race'] || '-'
        attribute    = card_data['attribute'] || '-'
        level        = card_data['level'] || '-'
        desc         = card_data['desc'] || '-'
        atk          = card_data['atk'] || 0
        def_val      = card_data['def'] || 0
        pict         = card_data['image_small']

        response = {
          image: pict,
          message: "*#{card&.dig('name') || 'Unknown'}*\n#{card&.dig('desc') || '-'}"
        }

        bot.api.send_photo(
          chat_id: chat_id,
          photo: response[:image],
          caption: response[:message],
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
