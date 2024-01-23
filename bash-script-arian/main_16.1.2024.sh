#!/bin/bash

json=$(curl -s 'https://api.openweathermap.org/data/2.5/weather?lat=47.36&lon=8.55&appid=a889fa2bffa32a36daedfe34e5f7c7e8')

name=$(echo "$json" | jq -r '.name')

weather_description=$(echo "$json" | jq -r '.weather[0].description')

visibility=$(echo "$json" | jq -r '.visibility')

wind_speed=$(echo "$json" | jq -r '.wind.speed')

main_temp_k=$(echo "$json" | jq -r '.main.temp')
main_feels_like_k=$(echo "$json" | jq -r '.main.feels_like')
main_humidity=$(echo "$json" | jq -r '.main.humidity')

temp_c=$(echo "$main_temp_k-273.15" | bc)
feels_like_c=$(echo "$main_feels_like_k-273.15" | bc)

db_host="172.16.17.160"
# db_host="ke.internet-box.ch:2206"
db_user="user02"
db_pass="MaSq-02"
db_name="weather-app-milari"
db_table_name="WeatherApp"


if (( $(echo "$temp_c > 18" | bc -l) )); then
    mail -s 'ACHTUNG: Warmes Wetter' -a From:\<arian89sh08@smart-mail.de\> arian.shkodra@edu.tbz.ch <<< "Es ist ${temp_c} C, gefuehlt wird es: ${feels_like_c} C, Sichtbarkei: ${visibility} m, Wind: ${wind_speed} m/s, Feuchtigkeit: ${main_huminity}%, Wetter beschreibung: ${weather_description}"
elif (( $(echo "$temp_c < 10" | bc -l) )); then
    mail -s 'ACHTUNG: Kaltes Wetter' -a From:\<arian89sh08@smart-mail.de\> arian.shkodra@edu.tbz.ch <<< "Es ist ${temp_c} C, gefuehlt wird es: ${feels_like_c} C, Sichtbarkei: ${visibility} m, Wind: ${wind_speed} m/s, Feuchtigkeit: ${main_huminity}%, Wetter beschreibung: ${weather_description}"
fi 

sql="INSERT INTO ${db_table_name} (name, weather_description, visibility, wind_speed, main_humidity, temp_c, feels_like_c) VALUES ('${name}', '${weather_description}', '${visibility}', '${wind_speed}', '${main_humidity}', '${temp_c}', '${feels_like_c}')"

mysql -h $db_host -u $db_user -p$db_pass $db_name -e "$sql"

# chronjob
