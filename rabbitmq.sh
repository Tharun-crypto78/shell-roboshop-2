#!/bin/bash

source ./common.sh
app_name=rabbitmq
check_root

echo "Please enter rabbitmq password to setup"
read -s RABBITMQ_PASSWD

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "Adding rabbitmq repo"

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "Installing Rabbitmq server"

systemctl enable rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Enabling rabbitmq server"

systemctl start rabbitmq-server &>>$LOG_FILE
VALIDATE $? "starting rabbitmq server"

# setting the username and password
rabbitmqctl add_user roboshop $RABBITMQ_PASSWD &>>$LOG_FILE # password should be roboshop123, because it has been already configured the same in the payment and dispatch code too.
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE

print_time