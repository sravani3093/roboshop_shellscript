#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"
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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOGFILE
VALIDATE $? "remirepo installed"

dnf module enable redis:remi-6.2 -y &>> $LOGFILE 
VALIDATE $? "redis enabled"

rpm -qa | grep -i redis  &>> $LOGFILE
if [ $? -ne 0 ]
then 
    dnf install redis -y &>> $LOGFILE
    VALIDATE $? "REDIS INSTALLED"
else
    echo -e "redis already installed ...$Y SKIPPING $N"
fi

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf &>> $LOGFILE
VALIDATE $? "Servcer access enabling is"

systemctl enable redis &>> $LOGFILE
VALIDATE $? "enable redis is"

systemctl start redis &>> $LOGFILE
VALIDATE $? "redis service start is"



