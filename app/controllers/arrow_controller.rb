class Arrow
  ARROW_MAP = {
    'Top' => '↑',
    'Bottom' => '↓',
    'Left' => '←',
    'Right' => '→',
    'Top-Left' => '↖',
    'Top-Right' => '↗',
    'Bottom-Left' => '↙',
    'Bottom-Right' => '↘'
  }.freeze

  def self.scan(input)
    case input
    when Array
      input.map { |i| ARROW_MAP[i] || i }.join(' ')
    when String
      ARROW_MAP[input] || input
    else
      '-'
    end
  end
end
