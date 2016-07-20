#! /usr/bin/node
//
// Peer connection script.
// 
// Attempts to connect to base node.
//

//Used to set exit code.
const process=require("process")

//Used for data verification.
const siad=require("/go/node_modules/sia.js")

//Used to emulate user experience.
const child=require("child_process")
const siac=(inputArgs, input) => child.spawnSync("siac", inputArgs||[], { input: input||"" })

const dns=require("dns")

let errors=0
const socketPath="/var/run/scope/plugins/peer_connection.sock"
const http=require("http")
http.get({
    socketPath: "/run/docker.sock",
    path: `/containers/${process.env.HOSTNAME}/json`
}, (info) => {
    var body = '';
    info.on('data', function(d) {
            body += d;
        });
        info.on('end', function() {
        info = JSON.parse(body)
        const server = http.createServer((req, res) => {
        let process_nodes = {}
        let node_key = info.Id + ";<container>"
        console.log(`Updated number of errors: ${node_key} has ${errors} errors`)
        process_nodes=[
           {
            id: node_key,
            'metrics': [
                {
                    id: 'test_errors',
                    'samples': [{
                        'date': new Date(),
                        'value': errors,
                    }]
                }
            ] 
          }
        ]
    
        report = {
            'Processes': {
                'nodes': process_nodes,
                'metric_templates': {
                    'test_errors': {
                        'id':       'test_errors',
                        'label':    'Test Errors',
                        'priority': 0.1,
                    }
                }
            },
            'Plugins': [
                {
                    'id': 'test_errors',
                    'label': 'Test Errors',
                    'description': 'Logs errors for each process',
                    'interfaces': ['reporter'],
                    'api_version': '1',
                }
            ]
        }
        res.write(JSON.stringify(report))
        res.end();
    });
    server.on('clientError', (err, socket) => {
      socket.end('HTTP/1.1 400 Bad Request\r\n\r\n');
    });
    server.listen(socketPath)
})
})

let baseip = ""
init = () => {
    //Lookup base node's ip address.
    dns.lookup("base", { family: 4 }, (e, ip) => {
        if (e){ throw(e) }
        baseip = ip
        main()
    })
}

main = () => {
    console.log(siac(["gateway", "connect", baseip+":9981"]).stderr.toString())
    
    let testTimeout = setTimeout(() => {
        clearInterval(testLoop)
        process.exitCode = 1
        console.log("ERROR: Test timed out.")
    }, 15000)

    let testCountdown = 0 //If we go five iterations with a stable peer we are good.
    let testLoop = setInterval(() => {
         try {
             siad.call("/gateway", (e, gateway) => {
                 console.log(gateway)
                 if (gateway.peers.length>=1){
                     siad.call("/consensus", (e, consensus) => {
                         if (consensus.synced === true){
                             testCooldown++
                             if (testCooldown==5){
                                 console.log("Test complete. Peer synced and connected to base.")
                                 //Process is return success.
                             } else {
                                 console.log(`WARN: Consensus not synced: ${consensus}`)
                                 testCountdown = 0
                             }
                         } else {
                             console.log(`WARN: Insufficent number of peers: ${gateway.peers}`)
                             testCountdown = 0
                         }
                     })
                  }
             })
         } catch (e) {
             console.log(`ERROR: ${e}`)
             process.exit(2)
             clearInterval(testLoop)
             clearTimeout(testTimeout) 
         }
    }, 1000)
 }

init()
