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

let baseip = ""
init = () => {
    //Lookup base nodes ip address.
    dns.lookup("base", { family: 4 }, (e, ip) => {
        if (e){ throw(e) }
        baseip = ip
        main()
    })
}

main = () => {
    //Don't connect to ourselves if we are the base node.
    if (baseip !== process.env.IP){
        siac(["gateway", "connect", baseip+":9981"]).stderr.toString()
    }
    
    let testTimeout = setTimeout(() => {
        clearInterval(testLoop)
        process.exitCode = 1
        console.log("ERROR: Test timed out.")
        siac(["stop"])
    }, 100000)

    let testCooldown = 0 //If we go five iterations with a stable peer we are good.
    let testLoop = setInterval(() => {
        try {
            siad.call("/gateway", (e, gateway) => {
                console.log(gateway)
                if (gateway.peers.length>=1){
                    siad.call("/consensus", (e, consensus) => {
                        if (consensus.synced === true){
                            testCooldown++
                            if (testCooldown==5){
                                const date = Math.round((new Date()).getTime()/1000)
                                console.log(`${date} SUCCESS: Test complete. Peer synced and connected to base!`)
                                clearInterval(testLoop)
                                clearTimeout(testTimeout)
                                //Process is return success.
                            } else {
                                console.log(`SYNC: Have peer and synced: Cooldown ${testCooldown}`)
                            }
                        } else {
                            console.log(`WARN: Consensus not synced: ${JSON.stringify(consensus)}`)
                            testCountdown = 0
                        }
                    })
                } else {
                    console.log(`Insufficient number of peers: ${gateway.peers.length}`)
                    testCooldown = 0
                } 
            })
        } catch (e) {
            siac(["stop"])
            console.log(`ERROR: ${e}`)
            clearInterval(testLoop)
            clearTimeout(testTimeout) 
            process.exit(2)
        }
    }, 1000)
 }

init()
