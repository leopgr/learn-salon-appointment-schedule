#!/bin/bash

PSQL_QUERY="/usr/bin/psql --username=freecodecamp --dbname=salon --tuples-only -c"

function fn_show_menu(){
# show a list of services
MENU=$($PSQL_QUERY "select service_id||') '||name from services order by service_id")
echo -e "$MENU" | sed -e 's/[[:space:]]*$//'
read SERVICE_ID_SELECTED

vNUMBER=0
re='^[0-9]+$'
if ! [[ $SERVICE_ID_SELECTED =~ $re ]] ; then
   MENU=$($PSQL_QUERY "select service_id||') '||name from services order by service_id")
   echo -e "$MENU" | sed -e 's/[[:space:]]*$//'
   read SERVICE_ID_SELECTED
   
fi

}

function fn_check_customer(){
   CUSTOMER_NAME=$($PSQL_QUERY "select count(*) from customers where phone='$CUSTOMER_PHONE'")
   if [ $CUSTOMER_NAME -eq 0 ]; then
      echo -e "\nI don't have a record for that phone number, what's your name?\n"
      read CUSTOMER_NAME
      $PSQL_QUERY "insert into customers(phone, name) values('$CUSTOMER_PHONE','$CUSTOMER_NAME')"
   else
      CUSTOMER_NAME=$($PSQL_QUERY "select name from customers where phone='$CUSTOMER_PHONE'")
   fi

}

function fn_create_appointment(){
   CUSTOMER_ID=$($PSQL_QUERY "select customer_id from customers where phone='$CUSTOMER_PHONE'")

   $PSQL_QUERY "insert into appointments (customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"

}

#main
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

fn_show_menu

vSERV_OK=0
vSERV_OK=$($PSQL_QUERY "select count(*) from services where service_id=$SERVICE_ID_SELECTED")
while [ $vSERV_OK -eq 0 ]
do
   echo -e "\nI could not find that service. What would you like today?"
   fn_show_menu
   vSERV_OK=$($PSQL_QUERY "select count(*) from services where service_id=$SERVICE_ID_SELECTED")
done

vSERV_NAME=$($PSQL_QUERY "select name from services where service_id=$SERVICE_ID_SELECTED")

echo -e "What's your phone number?"
read CUSTOMER_PHONE

fn_check_customer

echo -e "\nWhat time would you like your $vSERV_NAME, $CUSTOMER_NAME?\n"

read SERVICE_TIME

fn_create_appointment

echo -e "I have put you down for a cut at $SERVICE_TIME, $CUSTOMER_NAME."