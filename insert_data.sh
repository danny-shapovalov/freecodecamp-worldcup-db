#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo "$($PSQL "TRUNCATE teams, games")"

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT W_GOALS O_GOALS
do
  if [[ $YEAR != year ]]
  then

    W_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    if [[ -z $W_TEAM_ID ]]
    then
      TEAM_ADDED=$($PSQL "INSERT INTO teams (name) VALUES ('$WINNER')")
      if [[ $TEAM_ADDED == "INSERT 0 1" ]]
      then
        echo Added winner team: $WINNER
        W_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
      fi
    fi
    O_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
    if [[ -z $O_TEAM_ID ]]
    then
      TEAM_ADDED=$($PSQL "INSERT INTO teams (name) VALUES ('$OPPONENT')")
      if [[ $TEAM_ADDED == "INSERT 0 1" ]]
      then
        echo Added opponent team: $OPPONENT
        O_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
      fi
    fi

    INSERTION=$($PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $W_TEAM_ID, $O_TEAM_ID, $W_GOALS, $O_GOALS)")
    echo Inserted into games: $YEAR $ROUND match between $WINNER and $OPPONENT

  fi
done
