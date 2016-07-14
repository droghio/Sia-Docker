const http = require('http');
const server = http.createServer((req, res) => {
    var rawAddress = req.socket.remoteAddress.split(':')
    res.write(rawAddress[rawAddress.length-1])
    res.end();
});
server.listen(80)
