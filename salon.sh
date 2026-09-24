#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo "$1"
  fi

  LIST_SERVICE=$($PSQL "select service_id, name from services")
  echo "$LIST_SERVICE" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done

    echo -e "\nWhich one would you like to rent?"
    read SERVICE_ID_SELECTED

    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      SERVICE_ID_OK=$($PSQL "select service_id from services where service_id=$SERVICE_ID_SELECTED")
      if [[ -z $SERVICE_ID_OK ]]
      then
        MAIN_MENU "I could not find that service. What would you like today?"
      else
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE

        CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")

        if [[ -z $CUSTOMER_NAME ]]
        then
          echo -e "\nI don't have a record for that phone number, what's your name?"
          read CUSTOMER_NAME

          INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
        fi

        CUSTOMER_ID=$($PSQL "select customer_id from customers where name='$CUSTOMER_NAME'")
        SERVICE_NAME=$($PSQL "SELECT name from services where service_id=$SERVICE_ID_OK")

        echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
        read SERVICE_TIME
        INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_OK, '$SERVICE_TIME')")
        
        echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
        
      fi
    fi
}

MAIN_MENU
