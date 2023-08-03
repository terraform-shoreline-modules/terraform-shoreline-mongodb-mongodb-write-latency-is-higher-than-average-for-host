
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# MongoDB Write Latency Higher Than Average
---

This incident type refers to a situation where the write latency for a MongoDB database is higher than the average. This might cause delays in write operations and can negatively impact the performance of the system. The incident might be triggered by an alert that indicates that the write latency has exceeded a certain threshold, and it requires immediate attention from a software engineer to identify and resolve the underlying issue. The incident can be resolved by identifying and fixing the root cause of the latency issue, and ensuring that the system is functioning within acceptable performance parameters.

### Parameters
```shell
# Environment Variables

export MONGODB_PORT="PLACEHOLDER"

export MONGODB_HOST="PLACEHOLDER"

export MONGODB_PASSWORD="PLACEHOLDER"

export IP_ADDRESS="PLACEHOLDER"

export MONGODB_USERNAME="PLACEHOLDER"

export SERVER_ADDRESS="PLACEHOLDER"
```

## Debug

### Check if MongoDB is running
```shell
systemctl status mongodb
```

### Check if MongoDB is listening on the correct port
```shell
netstat -tln | grep ${MONGODB_PORT}
```

### Check for any errors in the MongoDB log file
```shell
tail -n 100 /var/log/mongodb/mongodb.log
```

### Check the status of the MongoDB replica set
```shell
mongo --host ${MONGODB_HOST} --port ${MONGODB_PORT} --eval "rs.status()"
```

### Check the latency of MongoDB writes
```shell
mongo --host ${MONGODB_HOST} --port ${MONGODB_PORT} --eval "db.getSiblingDB('admin').runCommand({whatsmyuri: 1}).you" # get the IP address of the current connection

mongostat --host ${MONGODB_HOST} --port ${MONGODB_PORT} --discover --authenticationDatabase admin --username ${MONGODB_USERNAME} --password ${MONGODB_PASSWORD} --rowcount 1 --noheaders | grep ${IP_ADDRESS} | awk '{print $NF}' # get the write latency of the current connection
```

### Check the disk space usage of the MongoDB server
```shell
df -h /var/lib/mongodb
```

### Check the CPU and memory usage of the MongoDB process
```shell
top -p $(pidof mongod)
```


## Repair

### Check if there are any long-running queries or operations that are causing the high write latency, optimize or terminate them if possible.
```shell

#!/bin/bash

OP_ID="PLACEHOLDER"

# Connect to the MongoDB server using the ${USERNAME}, ${PASSWORD}, and ${SERVER_ADDRESS} parameters.

mongo --username ${USERNAME} --password ${PASSWORD} ${SERVER_ADDRESS}

# Check for any long-running queries or operations using the "currentOp" command.

db.currentOp({"secs_running": {"$gte": 60}})

# If there are any long-running queries or operations, terminate them using the "killOp" command.

db.killOp(${OP_ID})

# Close the MongoDB connection.

exit

```