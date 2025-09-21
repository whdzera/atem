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
  random: ['/random'],
  search: ['/search']
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

      # /start
      if COMMANDS[:start].include?(text)
        bot.api.send_message(
          chat_id: chat_id,
          text: 'Welcome to Atem bot! Use /help for usage.',
          parse_mode: 'Markdown'
        )

      # /info
      elsif COMMANDS[:info].include?(text)
        response = General.info
        bot.api.send_message(
          chat_id: chat_id,
          text: response,
          parse_mode: 'Markdown'
        )

      # /help
      elsif COMMANDS[:help].include?(text)
        response = General.help
        bot.api.send_message(
          chat_id: chat_id,
          text: response,
          parse_mode: 'Markdown'
        )

      # /ping
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

      # /random
      elsif COMMANDS[:random].include?(text)

        card_data = Random.card
        card_name    = card_data['name']
        ban_ocg      = card_data['ban_ocg'] || '-'
        ban_tcg      = card_data['ban_tcg'] || '-'
        ban_md       = card_data['ban_md'] || '-'
        suffix       = card_data['suffix'] || ''
        type         = card_data['type'] || '-'
        race         = card_data['race'] || '-'
        attribute    = card_data['attribute'] || '-'
        level        = card_data['level'] || '-'
        linkval      = card_data['linkval'] || '-'
        linkmarkers  = card_data['linkmarkers'] || '-'
        desc         = card_data['desc'] || '-'
        atk          = card_data['atk'] || 0
        def_val      = card_data['def'] || 0
        pict         = card_data['image'][0]['image_url_cropped']

        response = if ['Spell Card', 'Trap Card', 'Skill Card'].include?(type)
                     {
                       image: pict,
                       message: "**#{card_name}**\n**Limit:** **OCG:** #{Banlist.scan(ban_ocg)} / **TCG:** #{Banlist.scan(ban_tcg)} / **MD:** #{Banlist.scan(ban_md)}\n**Type:** #{type}\n**Type:** #{type}\n\n#{desc}"
                     }

                   elsif ['Link Monster'].include?(type)
                     {
                       image: pict,
                       message: "**#{card_name}**\n**Limit:** **OCG:** #{Banlist.scan(ban_ocg)} / **TCG:** #{Banlist.scan(ban_tcg)} / **MD:** #{Banlist.scan(ban_md)}\n**Type:** #{type}\n" \
                                "**Type:** #{race} #{suffix}\n" \
                                "**Attribute:** #{attribute}\n" \
                                "**Link Rating:** #{linkval} / **Link Marker:** #{Arrow.scan(linkmarkers)}\n**ATK:** #{atk} **DEF:** #{def_val}\n\n#{desc}"
                     }

                   else
                     {
                       image: pict,
                       message: "**#{card_name}**\n**Limit:** **OCG:** #{Banlist.scan(ban_ocg)} / **TCG:** #{Banlist.scan(ban_tcg)} / **MD:** #{Banlist.scan(ban_md)}\n**Type:** #{type}\n" \
                                "**Type:** #{race} #{suffix}\n" \
                                "**Attribute:** #{attribute}\n" \
                                "**Level:** #{level}\n**ATK:** #{atk} **DEF:** #{def_val}\n\n#{desc}"
                     }
                   end

        bot.api.send_photo(
          chat_id: chat_id,
          photo: response[:image],
          caption: response[:message],
          parse_mode: 'Markdown'
        )

      # /search
      elsif text.start_with?('/search')
        query = text.sub('/search', '').strip

        if query.empty?
          bot.api.send_message(
            chat_id: chat_id,
            text: "Use the format:\n`/search <card_name>`",
            parse_mode: 'Markdown'
          )
          next
        end

        card_data = Search.name(query)

        if card_data.nil? || card_data.empty?
          bot.api.send_message(
            chat_id: chat_id,
            text: "Card not found: *#{query}*",
            parse_mode: 'Markdown'
          )
          next
        end

        card = card_data.is_a?(Array) ? card_data.first : card_data

        card_name    = card['name']
        ban_ocg      = card['ban_ocg'] || '-'
        ban_tcg      = card['ban_tcg'] || '-'
        ban_md       = card['ban_md'] || '-'
        suffix       = card['suffix'] || ''
        type         = card['type'] || '-'
        race         = card['race'] || '-'
        attribute    = card['attribute'] || '-'
        level        = card['level'] || '-'
        linkval      = card['linkval'] || '-'
        linkmarkers  = card['linkmarkers'] || '-'
        desc         = card['desc'] || '-'
        atk          = card['atk'] || 0
        def_val      = card['def'] || 0
        pict         = card['image'][0]['image_url_cropped']

        response = if ['Spell Card', 'Trap Card', 'Skill Card'].include?(type)
                     {
                       image: pict,
                       message: "**#{card_name}**\n" \
                                "**Limit:** **OCG:** #{Banlist.scan(ban_ocg)} / **TCG:** #{Banlist.scan(ban_tcg)} / **MD:** #{Banlist.scan(ban_md)}\n" \
                                "**Type:** #{type}\n\n#{desc}"
                     }
                   elsif ['Link Monster'].include?(type)
                     {
                       image: pict,
                       message: "**#{card_name}**\n" \
                                "**Limit:** **OCG:** #{Banlist.scan(ban_ocg)} / **TCG:** #{Banlist.scan(ban_tcg)} / **MD:** #{Banlist.scan(ban_md)}\n" \
                                "**Type:** #{type}\n" \
                                "**Race:** #{race} #{suffix}\n" \
                                "**Attribute:** #{attribute}\n" \
                                "**Link Rating:** #{linkval} / **Link Marker:** #{Arrow.scan(linkmarkers)}\n" \
                                "**ATK:** #{atk} **DEF:** #{def_val}\n\n#{desc}"
                     }
                   else
                     {
                       image: pict,
                       message: "**#{card_name}**\n" \
                                "**Limit:** **OCG:** #{Banlist.scan(ban_ocg)} / **TCG:** #{Banlist.scan(ban_tcg)} / **MD:** #{Banlist.scan(ban_md)}\n" \
                                "**Type:** #{type}\n" \
                                "**Race:** #{race} #{suffix}\n" \
                                "**Attribute:** #{attribute}\n" \
                                "**Level:** #{level}\n" \
                                "**ATK:** #{atk} **DEF:** #{def_val}\n\n#{desc}"
                     }
                   end

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
