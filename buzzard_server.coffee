#npm install socket.io
#npm install redis    : https://github.com/mranney/node_redis

http = require('http')
io   = require('socket.io')
url  = require('url')
path = require('path')
mime = require('mime')
fs   = require('fs')

# SERVE PAGES
httpServer = http.createServer((request, response) ->
    pathname = url.parse(request.url).pathname;
    filename = null
    if pathname == "/"
        filename = "public/index.html"
    else
        filename = path.join(process.cwd(), 'public', pathname)

    path.exists(filename, (exists) ->
        if(!exists)
            response.writeHead(404, {'Content-Type':'text/plain'})
            response.write("404 not found")
            response.end()
            return

        response.writeHead(200, {'Content-Type':mime.lookup(filename)})
        fs.createReadStream(filename, {
            'flags':'r',
            'encoding':'binary',
            'mode':'0666',
            'bufferSize':4 * 1024
        }).addListener('data', (chunk) ->
            response.write(chunk, 'binary')
        ).addListener('close', () ->
            response.end()
        )
    )
)

httpServer.listen('8888')

# SOCKET.IO DATA PUSHES
io          = io.listen(httpServer)
redis       = require('redis')
redisClient = redis.createClient()
connected_sockets = []
operators = ["uk_vodafone", "uk_o2", "uk_orange"]

io.sockets.on('connection', (socket) ->
    console.log("client connected")
    connected_sockets.push(socket)
    # init_data(socket)
    socket.emit('data_update', {'channel':'mt_sent', 'message':'aaa'})

)

setInterval(
    () ->
        now = timestamp() - 5
        keys = operators.map((operator) -> "mt_sent:#{operator}:#{now}")
        redisClient.mget(keys, (err, res) ->
            message = operators.map((operator, i) ->
                {
                    operator : operator,
                    time     : now,
                    value    : parseInt(res[i])
                }
            )
            console.log(message)

            for socket in connected_sockets
                socket.emit('mt_sent_update', message)
        )

, 1000)


# init_data = (socket) ->
#     now = timestamp()
#     for(t=(now - 60);t < now;t++) {
#         sendValue(socket, t)
#     }

timestamp = () ->
    Math.round(new Date().getTime() / 1000)
