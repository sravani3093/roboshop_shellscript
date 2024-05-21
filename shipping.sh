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
dnf install maven -y &>> $LOGFILE
VALIDATE $1 "MAVEN INSTALLED"

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

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
VALIDATE $? "shipping File Downloaded"

cd /app &>> $LOGFILE
VALIDATE $? "Changed the Directoy to  /app"

unzip  -o /tmp/shipping.zip &>> $LOGFILE
VALIDATE $? "File Unzip"

mvn clean package
VALIDATE $? "clean package completed"

mv target/shipping-1.0.jar shipping.jar
VALIDATE $? "File moved"

cp /home/centos/roboshop_shellscript/shipping.service  /etc/systemd/system
VALIDATE $? "file copied"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "daemon-reload"

systemctl enable shipping  &>> $LOGFILE
VALIDATE $? "shipping enabled"

systemctl start shipping &>> $LOGFILE
VALIDATE $? "shipping started"

dnf install mysql -y &>> $LOGFILE
VALIDATE $? "MySql installed"

mysql -h mysql.mihir.cloud -uroot -pRoboShop@1 < /app/schema/shipping.sql 

systemctl restart shipping
VALIDATE $? "Shipping restarted"









