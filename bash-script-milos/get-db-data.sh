#!/bin/bash
 
# Make the API call and save the response
response=$(curl -s "https://api.openweathermap.org/data/2.5/weather?lat=47.36&lon=8.55&appid=a889fa2bffa32a36daedfe34e5f7c7e8")
 
# Parse the response and prepare the SQL query
name=$(echo $response | jq -r '.name')
weather_description=$(echo $response | jq -r '.weather_description')
visibility=$(echo $response | jq -r '.visibility')
wind_speed=$(echo $response | jq -r '.wind_speed')
main_humidity=$(echo $response | jq -r '.main_humidity')
temp_c=$(echo $response | jq -r '.temp_c')
feels_like_c=$(echo $response | jq -r '.feels_like_c')
 
sql="INSERT INTO WeatherApp (name, weather_description, visibility, wind_speed, main_humidity, temp_c, feels_like_c) VALUES ('$name', '$weather_main', '$weather_description', $visibility, $wind_speed, $main_humidity, $temp_c, $feels_like_c)"
 
# Insert the data into the database
mysql -u user02 -p -D weather-app-milari -e "$sql"
