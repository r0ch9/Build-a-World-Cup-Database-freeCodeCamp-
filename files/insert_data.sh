#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

add_team() {
  local team_name="$1"
  local team_id=$($PSQL "INSERT INTO teams (name) VALUES ('$team_name') ON CONFLICT (name) DO NOTHING RETURNING team_id;")
  if [[ -z $team_id ]]; then
    team_id=$($PSQL "SELECT team_id FROM teams WHERE name='$team_name';")
  fi
  echo $team_id
}

# Process games.csv and insert data
cat games.csv | while IFS=',' read year round winner opponent winner_goals opponent_goals
do
  # Skip the header row
  if [[ $year != "year" ]]; then
    # Add teams to the teams table and get their IDs
    add_team "$winner"
    add_team "$opponent"
    winner_id=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
    opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")

    # Insert the game data into the games table
    $PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals)
           VALUES ($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals);"
  fi
done

echo "Data inserted successfully."
