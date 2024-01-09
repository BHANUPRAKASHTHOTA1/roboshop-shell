#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp
# /home/centos/roboshop-logs/script-name-date.log
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ...... $R Failure $N"
        exit 1
    else
        echo -e "$2 ...... $G Success $N"
    fi
}
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> $LOGFILE
VALIDATE $? "Setting up NPM Source"
yum install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing Node JS"
useradd roboshop &>> $LOGFILE
VALIDATE $? "Adding user"
mkdir /app &>> $LOGFILE
VALIDATE $? "Creating app directory"
curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE
VALIDATE $? "downloading user artifact"
cd /app &>> $LOGFILE
VALIDATE $? "Moving into app directory"
unzip /tmp/user.zip &>> $LOGFILE
VALIDATE $? "unzipping User"
cd /app &>> $LOGFILE 
VALIDATE $? "Moving into app directory"
npm install &>> $LOGFILE 
VALIDATE $? "install NPM"
cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service &>> $LOGFILE
VALIDATE $? "copying user service"
systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "daemon reload"
systemctl enable user &>> $LOGFILE
VALIDATE $? "Enable user"
systemctl start user &>> $LOGFILE
VALIDATE $? "Start user"
cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "Copying mongo repo"
yum install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "Installing mongo client"
mongo --host 172.31.90.166 </app/schema/user.js &>> $LOGFILE
VALIDATE $? "loading user data into mongodb"