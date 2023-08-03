
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# High backend session usage in HAProxy
---

High backend session usage in HAProxy is an incident that occurs when the amount of backend sessions in use for a host reaches a detection threshold of 80%. When this happens, HAProxy denies additional clients until resource consumption drops, which could result in service disruptions. This incident may require modifying HAProxy's configuration to allow more sessions or migrating the HAProxy server to a bigger box.

### Parameters
```shell
# Environment Variables

export HAPROXY_PROCESS_ID="PLACEHOLDER"

export PATH_TO_HAPROXY_CONFIG_FILE="PLACEHOLDER"

export NEW_VALUE_FOR_MAXCONN_PARAMETER="PLACEHOLDER"

export NAME_OF_THE_BACKEND="PLACEHOLDER"

export PATH_TO_HAPROXY_LOG_FILE="PLACEHOLDER"

export PATH_TO_HAPROXY_CFG="PLACEHOLDER"
```

## Debug

### Check the status of HAProxy
```shell
systemctl status haproxy
```

### Check the current backend session usage for a specific host
```shell
echo "show stat" | socat /run/haproxy/admin.sock stdio | awk -F',' '{print $1,$2,$5}'
```

### Check the HAProxy configuration file
```shell
less /etc/haproxy/haproxy.cfg
```

### Check the current resource consumption of the HAProxy server
```shell
top
```

### Check the current network connections
```shell
netstat -anp | grep ${HAPROXY_PROCESS_ID}
```

### Multiple misbehaving clients that are not releasing backend sessions after use, causing a backlog of sessions.
```shell
bash

#!/bin/bash



# Set the necessary parameters

haproxy_config=${PATH_TO_HAPROXY_CFG}

backend_name=${NAME_OF_THE_BACKEND}

log_file=${PATH_TO_HAPROXY_LOG_FILE}



# Check the backend limit and current usage

backend_limit=$(grep -oP "$backend_name\s+maxconn\s+\K\d+" $haproxy_config)

backend_current=$(tail -n 1000 $log_file | grep "$backend_name" | grep "backend_http-in" | grep -c "queued")



if [ "$backend_current" -gt "$backend_limit" ]; then

    echo "The backend session usage is currently at $backend_current, which is greater than the limit of $backend_limit."

    echo "Please investigate the misbehaving clients and determine why they are not releasing backend sessions after use."

else

    echo "The backend session usage is currently at $backend_current, which is within the limit of $backend_limit."

fi


```

## Repair

### Set the path to the HAProxy configuration file
```shell
CONFIG_FILE=${PATH_TO_HAPROXY_CONFIG_FILE}
```

### Set the new value for maxconn parameter
```shell
NEW_MAXCONN=${NEW_VALUE_FOR_MAXCONN_PARAMETER}
```

### Replace the old maxconn parameter with the new value in the configuration file
```shell
sed -i "s/^maxconn.*$/maxconn $NEW_MAXCONN/" $CONFIG_FILE
```

### Restart the HAProxy service to apply the changes
```shell
systemctl restart haproxy.service
```

### Check if the service is running
```shell
if [ "$(systemctl is-active haproxy.service)" = "active" ]; then

    echo "HAProxy service restarted successfully"

else

    echo "Failed to restart HAProxy service"

fi
```