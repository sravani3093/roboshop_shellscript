#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"
MONGODB_HOST=mongodb.mihir.cloud
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE=/tmp/$0_$TIMESTAMP.log #Generating the log file
echo "script execution started at : $TIMESTAMP " &>>$LOGFILE
VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2 is $R FAILED $N"
        
    else
        echo  -e "$2 is $G SUCCESSFULL $N"
    fi
}

if [ $ID -ne 0 ] #checking the root user
then
    echo -e " $R you are not a root,please run as root user $N"
    exit 1
else
    echo -e " $G proceed to runthe script $N"
fi
dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "module disable nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "module enable nodejs:18"

rpm -qa | grep -i nodejs
if [ $? -ne 0 ]
then
   dnf install nodejs -y &>> $LOGFILE
   VALIDATE $? "nodejs installation"
else 
    echo -e  "nodejs is already installed $Y SKIPPING $N"
fi

id roboshop
if [ $? -ne 0 ]
then 
    useradd roboshop &>> $LOGFILE
    VALIDATE $?  "USER ADDED"
else 
    echo "USER roboshop already Exist"
fi
mkdir  -p /app &>> $LOGFILE
VALIDATE $?  "app Directory"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE
VALIDATE $? "User File Downloaded"

unzip  -o /tmp/user.zip &>> $LOGFILE
VALIDATE $? "File Unzip"

npm install &>> $LOGFILE
VALIDATE $? "Dependecies Installed"

cp /home/centos/roboshop_shellscript/user.service /etc/systemd/system &>> $LOGFILE
VALIDATE $? "File copied successfully"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "daemon-reload"

systemctl enable user  &>> $LOGFILE
VALIDATE $? "user enabled"

systemctl start user &>> $LOGFILE
VALIDATE $? "user started"

cp /home/centos/roboshop_shellscript/mongo.repo /etc/yum.repos.d &>> $LOGFILE #copying the repo file
VALIDATE $? "mongo repo copied"

rpm -qa | grep -i mongodb-org-shell
if [ $? -ne 0 ]
then 
    dnf install mongodb-org-shell -y &>> $LOGFILE
    VALIDATE $? "MONGODB INSTALLED"
else 
    echo -e " MONGODB IS ALREADY INSTALLED ... $Y SKIPPING $N"
fi

mongo --host $MONGODBU_HOST </app/schema/catalogue.js &>> $LOGFILE
VALIDATE $? "Users loaded"







