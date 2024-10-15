#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

# display a numbered list of services
SERVICES=$($PSQL "SELECT * FROM services")
echo "$SERVICES" | sed 's/|/) /'

# prompt for service_id
read SERVICE_ID_SELECTED

# if service doesn't exist
while [[ -z $($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED") ]]
do
  # display services again
  echo -e "\nI could not find that service. What would you like today?"
  echo "$SERVICES" | sed 's/|/) /'

  # prompt for input again
  read SERVICE_ID_SELECTED
done

# prompt for phone number
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# if customer doesn't exist
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
if [[ -z $CUSTOMER_NAME ]]
then
  # prompt for customer's name
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME

  # insert customer's phone and name into table
  $PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')"
fi

# prompt for service time
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

# insert data into appointments table
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
$PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"

# output success message
echo -e "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
