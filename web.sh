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

rpm -qa | grep -i nginx
if [ $? -ne 0 ]
then
   dnf install nginx -y &>> $LOGFILE
   VALIDATE $? "nodejs installation"
else 
    echo -e  "nginx is already installed $Y SKIPPING $N"
fi

systemctl enable nginx &>> $LOGFILE
VALIDATE $? "Enable nginx"

systemctl start nginx &>> $LOGFILE
VALIDATE $? "start nginx"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE
VALIDATE $? "remove html"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE
VALIDATE $? "Downloaded "

cd /usr/share/nginx/html &>> $LOGFILE
VALIDATE $? "change directory"

unzip  -o /tmp/web.zip &>> $LOGFILE
VALIDATE $? "File unzip"

cp /home/centos/roboshop_shellscript/roboshop.conf /etc/nginx/default.d &>> $LOGFILE
VALIDATE $? "File copy"

systemctl restart nginx &>> $LOGFILE
VALIDATE $? "nginx restart"



