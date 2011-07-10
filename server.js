/* npm install socket.io
 * npm install redis    : https://github.com/mranney/node_redis
 *
 */

var http = require('http');
var io = require('socket.io');
var fs = require('fs');

server = http.createServer(function(req, res) {
    fs.readFile('./client.html', function(err, data) {
    res.writeHead(200, {'Content-Type': 'text/html'});
    res.write(data, 'utf8');
    res.end();
    });
});

server.listen('8888');

var io = io.listen(server);

io.sockets.on('connection', function(socket) {
    connectedSocket = socket;
    console.log("connected");
    // setInterval(function() {
    // socket.emit('buzzard', "hello world");
    // }, 1000);
    var redis = require('redis');
    var client = redis.createClient();
    client.on("subscribe", function(channel, count) {
        socket.emit('buzzard', "subscribed to " + channel);
    });

    client.on("message", function(channel, message) {
        socket.emit("buzzard", channel + ":" + message);
    });

    client.subscribe("mt_sent");
});

