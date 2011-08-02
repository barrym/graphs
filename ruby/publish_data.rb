require 'redis'
require 'json'

redis = Redis.new

candidates = %w(Barry Luca Misha David Toons)

while true do

  redis.publish :votes, {:name => candidates[rand(candidates.size)], :votes => 1}.to_json

  sleep 0.1
end
