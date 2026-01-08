#!/usr/bin/bash

# --- Variables ---
DATE=$(date)
MACHINE=$(uname -n)

# --- Disk usage check ---
dusage=$(df -Ph | grep -vE '^tmpfs|cdrom' | sed s/%//g | awk '{if($5>70) print $0;}')
fscount=$(echo "$dusage" | wc -l )

# --- Email alert using Python SMTP ---
if [ "$fscount" -ge 1 ]; then
python3 - <<EOF
import smtplib
from email.mime.text import MIMEText

# Email body and subject
body = """Disk Space Alert on $MACHINE at $DATE

$dusage
"""
msg = MIMEText(body)
msg['Subject'] = "Disk Space Alert on $MACHINE at $DATE"
msg['From'] = "server@example.com"      # Replace with your sender email
msg['To'] = "abc@example.com" # Replace with recipient email

# SMTP server configuration (Gmail example)
smtp_server = "smtp.gmail.com"
smtp_port = 587
smtp_user = "abcd@example.com"       # Replace with your SMTP username
smtp_password = "xxxx xxxx xxxx xxxx"     # Replace with your SMTP app password

# Send the email
s = smtplib.SMTP(smtp_server, smtp_port)
s.starttls()
s.login(smtp_user, smtp_password)
s.send_message(msg)
s.quit()
EOF
fi

DISK_BEFORE=$(df -h / | awk 'NR==2 {print $3 " used, " $4 " available, " $5 " used"}')

REMOVED_IMAGES=$(docker image prune -af --filter "dangling=true" --filter "until=24h" --format "{{.Repository}}:{{.Tag}} ({{.ID}})" 2>/dev/null)

UNUSED_IMAGES=$(docker images -q | while read img; do
    if [ -z "$(docker ps -a --filter ancestor=$img -q)" ]; then
        echo $img
    fi
done)

for img in $UNUSED_IMAGES; do
    docker rmi -f $img >/dev/null 2>&1
done

ALL_REMOVED=$(printf "%s\n%s" "$REMOVED_IMAGES" "$UNUSED_IMAGES")

DISK_AFTER=$(df -h / | awk 'NR==2 {print $3 " used, " $4 " available, " $5 " used"}')

if [ ! -z "$ALL_REMOVED" ]; then
python3 - <<EOF
import smtplib
from email.mime.text import MIMEText

body = """Docker Cleanup on $MACHINE at $DATE

Disk usage before cleanup: $DISK_BEFORE
Disk usage after cleanup : $DISK_AFTER

The following images were removed:

$ALL_REMOVED
"""
msg = MIMEText(body)
msg['Subject'] = "Docker Cleanup Report on $MACHINE at $DATE"
msg['From'] = "server@example.com"
msg['To'] = "abcd@example.com"

smtp_server = "smtp.gmail.com"
smtp_port = 587
smtp_user = "abcd@example.com"
smtp_password = "xxxx xxxx xxxx xxxx"

s = smtplib.SMTP(smtp_server, smtp_port)
s.starttls()
s.login(smtp_user, smtp_password)
s.send_message(msg)
s.quit()
EOF
fi

# --- Print disk info ---
date
df -P | awk '0+$5 >= 70 {print}'

# --- Optional cleanup ---
sudo apt autoremove -y
sudo apt autoclean
docker system df

