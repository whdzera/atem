class Banlist
  def self.scan(input)
    case input
    when 'Unlimited'
      '3'
    when 'Semi-Limited'
      '2'
    when 'Limited'
      '1'
    when 'Forbidden'
      '0'
    else
      'Undefined'
    end
  end
end
