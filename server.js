/* npm install socket.io
 * npm install redis    : https://github.com/mranney/node_redis
 *
 */

var http = require('http'),
    io = require('socket.io'),
    url = require('url'),
    path = require('path'),
    mime = require('mime'),
    fs = require('fs');

var httpServer = http.createServer(function(request, response) {
    var pathname = url.parse(request.url).pathname;
    var filename;
    if(pathname == "/") {
        filename = "client.html";
    } else {
        filename = path.join(process.cwd(), 'public', pathname);
    }

    path.exists(filename, function(exists) {
        if(!exists) {
            response.writeHead(404, {'Content-Type':'text/plain'});
            response.write("404 not found");
            response.end();
            return;
        }

        response.writeHead(200, {'Content-Type':mime.lookup(filename)});
        fs.createReadStream(filename, {
            'flags':'r',
            'encoding':'binary',
            'mode':'0666',
            'bufferSize':4 * 1024
        }).addListener('data', function(chunk) {
            response.write(chunk, 'binary');
        }).addListener('close', function() {
            response.end();
        });

    });
});

httpServer.listen('8888');

var io = io.listen(httpServer);

io.sockets.on('connection', function(socket) {
    console.log("client connected");
    // setInterval(function() {
    // socket.emit('buzzard', "hello world");
    // }, 1000);
    var redis = require('redis');
    var client = redis.createClient();
    client.on("subscribe", function(channel, count) {
        socket.emit('redis_pub_sub', "subscribed to " + channel);
    });

    client.on("message", function(channel, message) {
        socket.emit('redis_pub_sub', {'channel':channel, 'message':message});
    });

    client.subscribe("mt_sent");
});

