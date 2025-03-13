#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
    echo -e "\nWelcome to My Salon, how can I help you?\n"

    # Display services
    SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
   echo "$SERVICES" | while IFS='|' read SERVICE_ID NAME
    do
        echo "$SERVICE_ID) $NAME"
    done

    # Get service selection
    read SERVICE_ID_SELECTED

    # Check if service exists
    SERVICE_EXISTS=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_EXISTS ]]
    then
        MAIN_MENU
    else
        # Get customer phone number
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE

        # Check if customer exists
        CUSTOMER_EXISTS=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        if [[ -z $CUSTOMER_EXISTS ]]
        then
            # Get customer name
            echo -e "\nI don't have a record for that phone number, what's your name?"
            read CUSTOMER_NAME

            # Insert new customer
            INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
        else
            CUSTOMER_NAME=$CUSTOMER_EXISTS
        fi

        # Get appointment time
        echo -e "\nWhat time would you like your appointment, $CUSTOMER_NAME?"
        read SERVICE_TIME

        # Get customer_id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

        # Insert appointment
        INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

        # Get service name
        SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

        # Output confirmation
        echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
}

MAIN_MENU