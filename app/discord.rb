require 'discordrb'
require 'logger'
require 'dotenv'
Dotenv.load(File.expand_path('../config/.env', __dir__))
Dir[File.join(__dir__, 'controllers/*.rb')].sort.each do |file|
  require_relative file
end

TOKEN     = ENV.fetch('token_discord')
SERVER_ID = ENV.fetch('server_id_discord')
CLIENT_ID = ENV.fetch('client_id_discord')
logger = Logger.new($stdout)
logger.level = Logger::INFO

begin
  logger.info "[#{Time.now}] Starting Atem Discord Bot..."

  bot = Discordrb::Bot.new(
    token: TOKEN,
    client_id: CLIENT_ID,
    intents: %i[server_messages server_members],
    compress_mode: :large
  )

  # Register global slash commands (add 'server_id: SERVER_ID' for development)
  bot.register_application_command(:info, 'Information bot')
  bot.register_application_command(:help, 'Help command')
  bot.register_application_command(:ping, 'Check bot latency')
  bot.register_application_command(:random, 'Get a random Yu-Gi-Oh card')
  bot.register_application_command(:search, 'Search Yu-Gi-Oh card by name') do |cmd|
    cmd.string('name', 'input card name', required: true)
  end
  bot.register_application_command(:art, 'Search art Yu-Gi-Oh card by name') do |cmd|
    cmd.string('name', 'input card name', required: true)
  end
  bot.register_application_command(:img, 'Search image Yu-Gi-Oh card by name') do |cmd|
    cmd.string('name', 'input card name', required: true)
  end
  bot.register_application_command(:list, 'Get list of Yu-Gi-Oh cards') do |cmd|
    cmd.string('name', 'input card name', required: true)
  end

  # Bot ready event
  bot.ready do |_event|
    bot.game = '/search'
    logger.info "[#{Process.pid} #{Time.now}] Running Bot - Discord"
  end

  # Bot Mention
  bot.mention do |event|
    user = event.user
    event.respond("Hello #{user.mention}, you can use the slash command `/help` to see the available commands!")
  end

  # /info
  bot.application_command(:info) do |event|
    response = General.info
    event.respond(content: response)
    logger.info "Command used by #{event.user.username}: /info"
  end

  # /info
  bot.application_command(:help) do |event|
    response = General.help
    event.respond(content: response)
    logger.info "Command used by #{event.user.username}: /help"
  end

  # /Ping
  bot.application_command(:ping) do |event|
    start_time = Time.now
    event.defer

    latency = Ping.calculate_latency(start_time)

    event.edit_response(content: Ping.with_latency(latency))

    logger.info "Command used by #{event.user.username}: /ping"
  rescue StandardError => e
    event.respond(content: "Error calculating ping: #{e.message}")
  end

  # /random
  bot.application_command(:random) do |event|
    event.defer(ephemeral: false)

    card_data    = Random.card
    card_name    = card_data['name']
    link         = card_data['card_url']
    type_info    = card_data['color']
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

    if ['Spell Card', 'Trap Card', 'Skill Card'].include?(type)
      event.edit_response do |builder|
        builder.content = ''
        builder.add_embed do |embed|
          embed.colour = type_info.delete_prefix('#').to_i(16)
          embed.title = card_name
          embed.url   = link if link
          embed.add_field(
            name: '',
            value: "**Limit :** **OCG:** #{Banlist.scan(ban_ocg)} / **TCG:** #{Banlist.scan(ban_tcg)}\n**Type:** #{type}"
          )
          embed.add_field(name: 'Description', value: desc)
          embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: pict) if pict
        end
      end

    else
      event.edit_response do |builder|
        builder.content = ''
        builder.add_embed do |embed|
          embed.colour = type_info.delete_prefix('#').to_i(16)
          embed.title = card_name
          embed.url   = link if link
          embed.add_field(
            name: '',
            value: "**Limit :** **OCG:** #{Banlist.scan(ban_ocg)} / **TCG:** #{Banlist.scan(ban_tcg)}\n**Type:** #{race} #{suffix}\n**Attribute:** #{attribute}\n**Level:** #{level}"
          )
          embed.add_field(name: 'Description', value: desc)
          embed.add_field(name: 'ATK', value: atk.to_s, inline: true)
          embed.add_field(name: 'DEF', value: def_val.to_s, inline: true)
          embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: pict) if pict
        end
      end
    end

    logger.info "Command used by #{event.user.username}: /random"
  rescue StandardError => e
    logger.error "Error occurred while processing /random command: #{e.message}"
  end

  # /search <name>
  bot.application_command(:search) do |event|
    input = begin
      event.options['name']
    rescue StandardError
      nil
    end

    if input.nil?
      event.respond(content: 'Use the format: /search name:<card_name>')
      next
    end

    event.defer(ephemeral: false)

    card_data = Search.name(input)

    if card_data && card_data['name']
      card_name    = card_data['name']
      link         = card_data['card_url']
      type_info    = card_data['color']
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

      if ['Spell Card', 'Trap Card', 'Skill Card'].include?(type)
        event.edit_response do |builder|
          builder.content = ''
          builder.add_embed do |embed|
            embed.colour = type_info.delete_prefix('#').to_i(16)
            embed.title = card_name
            embed.url   = link if link
            embed.add_field(
              name: '',
              value: "**Limit :** **OCG:** #{Banlist.scan(ban_ocg)} / **TCG:** #{Banlist.scan(ban_tcg)}\n**Type:** #{type}"
            )
            embed.add_field(name: 'Description', value: desc)
            embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: pict) if pict
          end
        end

      else
        event.edit_response do |builder|
          builder.content = ''
          builder.add_embed do |embed|
            embed.colour = type_info.delete_prefix('#').to_i(16)
            embed.title = card_name
            embed.url   = link if link
            embed.add_field(
              name: '',
              value: "**Limit :** **OCG:** #{Banlist.scan(ban_ocg)}} / **TCG:** #{Banlist.scan(ban_tcg)}\n**Type:** #{race} #{suffix}\n**Attribute:** #{attribute}\n**Level:** #{level}"
            )
            embed.add_field(name: 'Description', value: desc)
            embed.add_field(name: 'ATK', value: atk.to_s, inline: true)
            embed.add_field(name: 'DEF', value: def_val.to_s, inline: true)
            embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: pict) if pict
          end
        end
      end
    else
      event.edit_response(content: "No card found with the name #{input}")
    end

    logger.info "Command used by #{event.user.username}: /search #{input}"
  rescue StandardError => e
    logger.error "Error occurred while processing /search command: #{e.message}"
  end

  # /art <name>
  bot.application_command(:art) do |event|
    input = begin
      event.options['name']
    rescue StandardError
      nil
    end

    if input.nil?
      event.respond(content: 'Use the format: /art name:<card_name>')
      next
    end

    event.defer(ephemeral: false)

    card_data = Search.name(input)
    type_info = card_data['color']
    pict = card_data['image_small']

    if pict.nil? || pict.empty?
      event.edit_response(
        embeds: [
          {
            color: 0xff1432,
            description: "**'#{card_name}' not found**"
          }
        ]
      )
    else
      event.edit_response(embeds: [{
                            color: type_info.delete_prefix('#').to_i(16), image: { url: pict }
                          }])
    end
    logger.info "Command used by #{event.user.username}: /art #{input}"
  rescue StandardError => e
    logger.error "Error occurred while processing /art command: #{e.message}"
  end

  # /img <name>
  bot.application_command(:img) do |event|
    input = begin
      event.options['name']
    rescue StandardError
      nil
    end

    if input.nil?
      event.respond(content: 'Use the format: /img name:<card_name>')
      next
    end

    event.defer(ephemeral: false)

    card_data = Search.name(input)
    type_info = card_data['color']
    pict = card_data['image']

    if pict.nil? || pict.empty?
      event.edit_response(
        embeds: [
          {
            color: 0xff1432,
            description: "**'#{card_name}' not found**"
          }
        ]
      )
    else
      event.edit_response(embeds: [{
                            color: type_info.delete_prefix('#').to_i(16), image: { url: pict }
                          }])
    end
    logger.info "Command used by #{event.user.username}: /img #{input}"
  rescue StandardError => e
    logger.error "Error occurred while processing /img command: #{e.message}"
  end

  # /list <name>
  bot.application_command(:list) do |event|
    input = begin
      event.options['name']
    rescue StandardError
      nil
    end

    if input.nil?
      event.respond(content: 'Use the format: /list name:<card_name>')
      next
    end

    event.defer(ephemeral: false)

    result = List.name(input, only: 'name')

    if result && result['cards'].any?
      cards = result['cards'].first(25) # Discord limit: max 25 options

      event.edit_response(
        content: "Select a card from **#{result['count']} results**:",
        components: [
          {
            type: 1, # Action Row
            components: [
              {
                type: 3, # Select Menu
                custom_id: 'card_select',
                placeholder: 'Choose a card',
                options: cards.map do |card|
                  {
                    label: card[0..99], # max 100 chars
                    value: card
                  }
                end
              }
            ]
          }
        ]
      )
    else
      event.edit_response(content: "No cards found with the name #{input}")
    end

    logger.info "Command used by #{event.user.username}: /list #{input}"
  rescue StandardError => e
    logger.error "Error in /list: #{e.message}"
    event.edit_response(content: "Something went wrong while fetching list for '#{input}'")
  end

  # /list search option
  bot.interaction_create do |event|
    data = event.interaction.data
    next unless data && data['custom_id'] == 'card_select'

    chosen_card = data['values']&.first
    next unless chosen_card

    card_data = Search.name(chosen_card)

    if card_data && card_data['name']
      card_name    = card_data['name']
      link         = card_data['card_url']
      type_info    = card_data['color']
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

      if ['Spell Card', 'Trap Card', 'Skill Card'].include?(type)
        event.respond do |builder|
          builder.content = ''
          builder.add_embed do |embed|
            embed.colour = type_info.delete_prefix('#').to_i(16)
            embed.title  = card_name
            embed.url    = link if link
            embed.add_field(
              name: '',
              value: "**Limit:** **OCG:** #{Banlist.scan(ban_ocg)} / **TCG:** #{Banlist.scan(ban_tcg)}\n**Type:** #{type}"
            )
            embed.add_field(name: 'Description', value: desc)
            embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: pict) if pict
          end
        end

      else
        event.respond do |builder|
          builder.content = ''
          builder.add_embed do |embed|
            embed.colour = type_info.delete_prefix('#').to_i(16)
            embed.title  = card_name
            embed.url    = link if link
            embed.add_field(
              name: '',
              value: "**Limit:** **OCG:** #{Banlist.scan(ban_ocg)} / **TCG:** #{Banlist.scan(ban_tcg)}\n" \
                     "**Type:** #{race} #{suffix}\n" \
                     "**Attribute:** #{attribute}\n" \
                     "**Level:** #{level}"
            )
            embed.add_field(name: 'Description', value: desc)
            embed.add_field(name: 'ATK', value: atk.to_s, inline: true)
            embed.add_field(name: 'DEF', value: def_val.to_s, inline: true)
            embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: pict) if pict
          end
        end
      end

    else
      event.respond(content: "No card found with the name #{chosen_card}")
    end
  end

  bot.run
rescue StandardError => e
  logger.error "[Unhandled Error] #{e.class}: #{e.message}"
  logger.error e.backtrace.join("\n")
  sleep 5
  retry
end
