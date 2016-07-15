const http = require('http');
const process = require('process')
process.on('SIGTERM', () => process.exit(0))
process.on('SIGINT', () =>  process.exit(0))
const server = http.createServer((req, res) => {
    var rawAddress = req.socket.remoteAddress.split(':')
    res.write(rawAddress[rawAddress.length-1])
    res.end();
});
server.listen(80)
