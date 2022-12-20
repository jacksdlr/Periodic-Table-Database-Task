#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

GET_DETAILS() {
  # get element details
  ELEMENT_DETAILS=$($PSQL "SELECT elements.atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, type FROM elements INNER JOIN properties ON elements.atomic_number=properties.atomic_number INNER JOIN types ON properties.type_id=types.type_id WHERE elements.atomic_number=$ATOMIC_NUMBER")
  # read each column and assign to variables
  echo $ELEMENT_DETAILS | while read ATOMIC_NUMBER BAR SYMBOL BAR NAME BAR ATOMIC_MASS BAR MELTING_POINT BAR BOILING_POINT BAR TYPE
  do
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  done
}

# check if argument is passed
if [[ -z $1 ]]
then
  # if not then ask for one
  echo "Please provide an element as an argument."
# check if argument is a number
elif [[ $1 =~ ^[0-9]+$ ]]
then
  # if true then query database to check it exists
  ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$1")
  # check if the element exists
  if [[ -z $ATOMIC_NUMBER ]]
  then
    echo "I could not find that element in the database."
  else
    # if found, run function to find and output the element details
    GET_DETAILS
  fi
else
  # find atomic number of element if argument matches any symbol in the table
  ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$1'")
  if [[ -z $ATOMIC_NUMBER ]]
  then
    # if it could not be find, do the same for any element names matching argument
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name='$1'")
    if [[ -z $ATOMIC_NUMBER ]]
    then
      echo "I could not find that element in the database."
    else
      GET_DETAILS
    fi
  else
    GET_DETAILS
  fi
fi
