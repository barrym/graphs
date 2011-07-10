require 'redis'

redis = Redis.new

while true do
  key = "mt_sent:" + Time.now.to_i.to_s
  value = rand(100)
  redis.set key, value
  redis.expire key, 60
  puts "set #{key} to #{value}"
  sleep 1
end
