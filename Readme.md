# Graphs

## Requirements

    brew install redis
    brew install node
    install npm : http://npmjs.org/
    npm install -g coffee-script

## Setup

    npm install

## Running

    redis-server
    coffee -c -b public/*/*.coffee
    node server.js

## Inserting data

    cd ruby
    bundle install
    bundle exec ruby generate_buzzard_data.rb
    bundle exec ruby publish_data.rb
