#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"
MONGODB=mogodb.mihir.cloud
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE=/tmp/$0_$TIMESTAMP.log #Generating the log file
echo "script execution started at : $TIMESTAMP " &>>$LOGFILE
VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2 is $R FAILED $N"
        exit 1
        
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

useradd roboshop &>> $LOGFILE
VALIDATE $?  "USER ADDED"

mkdir  -p /app &>> $LOGFILE
VALIDATE $?  "app Directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE
VALIDATE $? "Catalogue File Downloaded"

cd /app &>> $LOGFILE
VALIDATE $? "Changed the Directoy to  /app"

unzip /tmp/catalogue.zip &>> $LOGFILE
VALIDATE $? "File Unzip"

cd /app &>> $LOGFILE
VALIDATE $? "Changed the Directoy to  /app"

npm install &>> $LOGFILE
VALIDATE $? "Dependecies Installed"

cp catalogue.service /etc/systemd/system &>> $LOGFILE
VALIDATE $? "File copied"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "daemon-reload"

systemctl enable catalogue  &>> $LOGFILE
VALIDATE $? "catalogue enabled"

systemctl start catalogue  &>> $LOGFILE
VALIDATE $? "catalogue started"

cp mongo.repo /etc/yum.repos.d &>> $LOGFILE #copying the repo file
VALIDATE $? "mongo repo copied "

rpm -qa | grep -i mongodb-org-shell
if [ $? -ne 0 ]
then 
    dnf install mongodb-org-shell -y &>> $LOGFILE
    VALIDATE $? "MONGODB INSTALLED"
else 
    echo -e " MONGODB IS ALREADY INSTALLED ... $Y SKIPPING $N"
fi

mongo --host $MONGODB </app/schema/catalogue.js &>> $LOGFILE
VALIDATE $? "catalogue loaded "


