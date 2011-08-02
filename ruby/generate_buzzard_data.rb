require 'redis'

redis = Redis.new

@operators = [:uk_vodafone, :uk_o2, :uk_orange, :uk_tmobile, :uk_three]
# @operators = [:uk_vodafone, :uk_o2]

while true do
  @operators.each do |operator|
    # Hack to clear redis, shouldnt do this every time. Or maybe we do?
    redis.sadd "registered_operators", operator
    redis.expire "registered_operators", 60

    key = "mt_sent:#{operator}:" + Time.now.to_i.to_s
    value = rand(30)
    redis.incrby key, value
    redis.expire key, 60
    puts "incrby #{value} #{key}"
  end

  sleep 0.01
end
