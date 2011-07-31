require 'redis'

redis = Redis.new

@operators = [:uk_vodafone, :uk_o2, :uk_orange, :uk_tmobile, :uk_three]

@operators.each do |operator|
  redis.sadd "registered_operators", operator
end

while true do
  @operators.each do |operator|
    key = "mt_sent:#{operator}:" + Time.now.to_i.to_s
    value = rand(30)
    redis.incrby key, value
    redis.expire key, 60
    puts "incrby #{value} #{key}"
  end

  sleep 0.01
end
