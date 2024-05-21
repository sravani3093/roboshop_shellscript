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

dnf module disable mysql -y &>> $LOGFILE
VALIDATE $? "MySQL Module Disabled"

cp /home/centos/roboshop_shellscript/mysql.repo /etc/yum.repos.d
VALIDATE $? "mySql repo copied "

############
#rpm -qa | grep -i mysql-community-server
#if [ $? -ne 0 ]
#then 
  #  dnf install mysql-community-server -y &>> $LOGFILE
 #   VALIDATE $? "Mysql INSTALLED"
#else 
 #   echo -e " Mysql IS ALREADY INSTALLED ... $Y SKIPPING $N"
#fi
#############3
dnf install mysql-community-server -y &>> $LOGFILE
VALIDATE $? "Installing MySQL Server"

systemctl enable mysqld &>> $LOGFILE
VALIDATE $? "mysql enabled"

systemctl start mysqld &>> $LOGFILE
VALIDATE $? "Mysql started"

#x =echo "please enter the password for roboshop user:"
#read -s x
##mysql_secure_installation --set-root-pass x &>> $LOGFILE
#VALIDATE $? "password set successfully"
#check the passwor is working or not

#mysql -uroot -px &>> $LOGFILE
#VALIDATE $? "password set successfully"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE
VALIDATE $? "Setting  MySQL root password"


