#!/bin/bash

# At 1st we need the root access for all --> so we need to check the root access 
set -e

failure(){
    echo "Failed at : $1 $2"
}

trap 'failure "${LINENO}" "${BASH_COMMAND}" ' ERR

START_TIME=$(date +%s)
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
# creating a variable here
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD # gives the pwd where the script is present

mkdir -p $LOGS_FOLDER
echo "Script started executing at: $(date)" | tee -a $LOG_FILE 

# Check the user has root privileges or not
if [ $USERID -ne 0 ]
then
    echo -e "$R ERROR:: please run this script with root access $N" | tee -a $LOG_FILE
    exit 1 #if you want to manually exit then give other than 0, upto 127
else
    echo "You are running with the root access" | tee -a $LOG_FILE
fi

# Following the commands present in the git repo user documentation
dnf module disable nodejs -y &>>$LOG_FILE
dnf module enable nodejs:20 -y &>>$LOG_FILE
dnf install nodejsfaslfh -y &>>$LOG_FILE

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
else
    echo -e "System user roboshop already created ... $Y SKIPPING $n"
fi

mkdir -p /app 
curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$LOG_FILE

rm -rf /app/* # to remove the content present inside the app directory
cd /app 
unzip /tmp/user.zip &>>$LOG_FILE
npm install &>>$LOG_FILE

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service &>>$LOG_FILE
systemctl daemon-reload &>>$LOG_FILE
systemctl enable user &>>$LOG_FILE
systemctl start user &>>$LOG_FILE

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "Script execution completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE