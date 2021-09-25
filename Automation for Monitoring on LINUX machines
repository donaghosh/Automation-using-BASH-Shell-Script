#!/usr/bin/bash

DATE=$(date)    //This variable will contain the current system time
MACHINE=$(uname -n)   //This variable will contain the hostname
CURRENT=$(df / | grep / | awk '{print $5}' | sed 's/%//g')    //This variable will contain the value of the filesystem has usage value greater than threshold  
THRESHOLD=70    //This variable will contain the threshold value

WORKER_STATE=$(systemctl show -P ActiveState airflow-worker | sed 's/ActiveState=//g') //This variable will contain the state of the service running on slave node

if [ "$CURRENT" -gt "$THRESHOLD" ]; then    //This will check the condition if any usage value is greater than threshold
    mail -s 'Airflow Disk Space Alert' xyz@example.com << EOF   //If condition is true it will send mail with subject line to the recepient 
$DATE   //It will print the current date in mail body
ALERT ON $MACHINE :    //It will print the machine name in mail body
df -P | awk '0+$5 >= 70 {print}'    //It will print all the rows where usage is greater than threshold
EOF
fi

if [ "$WORKER_STATE" != "active" ]; then    //This will check if the state of service is running or not in the server.
  mail -s 'Airflow Service Not Running Alert' xyz@example.com << EOF    //If condition is true it will send mail with subject line to the recepient
$DATE   //It will print the current date in mail body
ALERT ON $MACHINE :    //It will print the machine name in mail body
Airflow worker is $WORKER_STATE   //It will print the status of the server. e.g., inactive(dead)
EOF
dzdo systemctl restart airflow-worker   //It will restart the service
fi

date    //It will print the date on the LINUX machine
df -P | awk '0+$5 >= 70 {print}'    //It will print the rows where usage is greater than threshold on the LINUX machine
systemctl status airflow-worker   //It will show the status of service on the LINUX machine
systemctl status iptables   //It will show the status of service on the LINUX machine
