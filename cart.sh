#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp
# /home/centos/roboshop-logs/script-name-date.log
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$SCRIPT_NAME-$DATE.log
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

VALIDATE() {
    if [ $1 -ne 0 ]
    then
       echo -e "$2 ...... $R Failure $N"
        exit 1
    else
        echo -e "$2 ...... $G Success $N"
    fi
}

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> $LOGFILE
VALIDATE $? "Setup NodeJS repos"
yum install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing NodeJS "
useradd roboshop &>> $LOGFILE
VALIDATE $? "Adding the user"
mkdir /app &>> $LOGFILE
VALIDATE $? "Creating teh app directory"
curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE
VALIDATE $? "downloading the cart artifact"
cd /app &>> $LOGFILE
VALIDATE $? "moving to app directory"
unzip /tmp/cart.zip &>> $LOGFILE
VALIDATE $? "unzipping the artifact"
cd /app &>> $LOGFILE
VALIDATE $? "moving to app directory"
npm install &>> $LOGFILE 
VALIDATE $? "Insatlling npm"
cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service &>> $LOGFILE
VALIDATE $? "Copying the cart service"
systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "daemon reload"
systemctl enable cart &>> $LOGFILE
VALIDATE $? "enabling the cart"
systemctl start cart &>> $LOGFILE
VALIDATE $? "Starting the cart"