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
yum install python36 gcc python3-devel -y &>> $LOGFILE
VALIDATE $? "Insatlling python"
useradd roboshop &>> $LOGFILE
VALIDATE $? "adding user"
mkdir /app &>> $LOGFILE
VALIDATE $? "creating directory"
curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE
VALIDATE $? "downloading payment artifact"
cd /app &>> $LOGFILE 
VALIDATE $? "moving into app directory"
unzip /tmp/payment.zip &>> $LOGFILE
VALIDATE $? "unzipping payment artifact"
cd /app &>> $LOGFILE 
VALIDATE $? "moving into app directory"
pip3.6 install -r requirements.txt &>> $LOGFILE
VALIDATE $? "installing python requirements"
cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE
VALIDATE $? "copying payment service"
systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "daemon relaod"
systemctl enable payment &>> $LOGFILE
VALIDATE $? "enabling the payment"
systemctl start payment &>> $LOGFILE
VALIDATE $? "starting the payment"