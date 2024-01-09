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

yum install maven -y &>> $LOGFILE
VALIDATE $? "Install maven"
useradd roboshop &>> $LOGFILE
VALIDATE $? "add user "
mkdir /app &>> $LOGFILE
VALIDATE $? "creating a directory"
curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
VALIDATE $? "downloading shipping repo"
cd /app &>> $LOGFILE
VALIDATE $? "moving to app directory"
unzip /tmp/shipping.zip &>> $LOGFILE
VALIDATE $? "unzipping the shipping"
cd /app &>> $LOGFILE
VALIDATE $? "moving to app directory"
mvn clean package &>> $LOGFILE
VALIDATE $? "packaging shipping app"
mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE
VALIDATE $? "renaming the shipping"
cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE
VALIDATE $? "copying the shipping service"
systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "daemon reload"
systemctl enable shipping &>> $LOGFILE
VALIDATE $? "rnabling the shipping"
systemctl start shipping &>> $LOGFILE
VALIDATE $? "starting the shipping"
yum install mysql -y &>> $LOGFILE
VALIDATE $? "installing mysql client"
mysql -h 172.31.80.96 -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE
VALIDATE $? "setting up root password"
systemctl restart shipping &>> $LOGFILE
VALIDATE $? "restarting the shipping"