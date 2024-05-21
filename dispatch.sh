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
dnf install golang -y &>>$LOGFILE
VALIDATE $? "goland installed"
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

curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip &>> $LOGFILE
VALIDATE $? "dispatch File Downloaded"

cd /app &>> $LOGFILE
VALIDATE $? "Changed the Directoy to  /app"

unzip -o /tmp/dispatch.zip &>> $LOGFILE
VALIDATE $? "File Unzip"


go mod init dispatch &>> $LOGFILE
VALIDATE $?  "Dispatch"

go get &>> $LOGFILE
VALIDATE $?  "get"

go build &>> $LOGFILE
VALIDATE $? "build"

cp /home/centos/roboshop_shellscript/dispatch.service /etc/systemd/system &>> $LOGFILE
VALIDATE $? "File copied successfully"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "daemon-reload"

systemctl enable dispatch  &>> $LOGFILE
VALIDATE $? "dispatch enabled"

systemctl start dispatch &>> $LOGFILE
VALIDATE $? "dispatch started"






