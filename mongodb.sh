#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE=/var/log/$0_$TIMESTAMP.log #Generating the log file
echo "script execution started at : $TIMESTAMP " &>>$LOGFILE
VALIDATE(){
    if [ $1 -ne 0]
    then 
        echo  -e "$2 is $G SUCCESSFULL $N"
    else
        echo -e "$2 is $R FAILED $N"
    fi
}

if [ $ID -ne 0] #checking the root user
then
    echo -e " $R you are not a root,please run as root user $N"
    exit 1
else
    echo -e " $G proceed to runthe script $N"
fi

cp mongo.repo /etc/yum.repos.d &>>$LOGFILE #copying the repo file

rpm -qa | grep -i mongodb-org &>>$LOGFILE
if [ $? -ne 0 ]
then 
    dnf install mongodb-org -y &>>$LOGFILE #installing mongod package
    VALIDATE $? "MONGODB INSTALLED"
else
    echo -e "MONGODB is ALREADY INSTALLED $Y ..SKIPPING.. $N"
fi
systemctl enable mongod &>>$LOGFILE #enabling mongod
VALIDATE $? "mongod enabled"

systemctl start mongod &>>$LOGFILE #startingmongod services
VALIDATE $? "mongod started"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$LOGFILE #Allowing traffice to mongod
VALIDATE $? "ALLOW other server to access"

systemctl restart mongod &>>$LOGFILE #restarting mongod services
VALIDATE $? "Restart of mongod services"

