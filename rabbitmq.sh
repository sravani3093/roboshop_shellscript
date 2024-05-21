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
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOGFILE
VALIDATE $? "rabbitmq downloaded"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOGFILE
VALIDATE $? "yum repo config"

dnf install rabbitmq-server -y &>> $LOGFILE
VALIDATE $? "RABBITMQ INSTALLED"

systemctl enable rabbitmq-server &>> $LOGFILE
VALIDATE $? "RABBITMQ ENABLED"

systemctl start rabbitmq-server &>> $LOGFILE
VALIDATE $? "RABBITMQ STARTED"

rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE
VALIDATE $? "creating user"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE
VALIDATE $? "setting permission"

