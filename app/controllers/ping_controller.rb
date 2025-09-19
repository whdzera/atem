class Ping
  def self.calculate_latency(start_time)
    ((Time.now - start_time) * 1000).round
  end

  def self.say
    "Pong!"
  end

  def self.with_latency(latency)
    "Pong! Latency: #{latency}ms"
  end
end