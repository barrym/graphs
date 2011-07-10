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
var redis = require('redis');
var redisClient = redis.createClient();

io.sockets.on('connection', function(socket) {
    console.log("client connected");
    setInterval(function() {
        sendValue(socket);
    }, 1000);
});

function sendValue(socket) {
    now = timestamp() - 5;
    redisClient.get("mt_sent:" + now, function(err, res) {
        message = {
            time:now,
            value:res
        };
        socket.emit('data_update', {'channel':'mt_sent', 'message':message});
    });
}

function get_initial_data() {
    now = timestamp();
    return_data = [];
    for(t=(now - 60);t < now;t++) {
        return_data.push({
            time: t,
            value:12
        });
    }
    return return_data;
}

function timestamp() {
    return Math.round(new Date().getTime() / 1000);
}
