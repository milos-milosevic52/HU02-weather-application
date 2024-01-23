#!/bin/bash

API_KEY="a889fa2bffa32a36daedfe34e5f7c7e8"
API_ENDPOINT="https://api.openweathermap.org/data/2.5/weather?lat=47.36&lon=8.55&appid=${API_KEY}"

# json=$(curl -H ${API_ENDPOINT}${API_KEY})
json=$(curl -s 'https://api.openweathermap.org/data/2.5/weather?lat=47.36&lon=8.55&appid=a889fa2bffa32a36daedfe34e5f7c7e8')

name=$(echo "$json" | jq -r '.name')

weather_main=$(echo "$json" | jq -r '.weather[0].main')
weather_description=$(echo "$json" | jq -r '.weather[0].description')

visibility=$(echo "$json" | jq -r '.visibility')

wind_speed=$(echo "$json" | jq -r '.wind.speed')

main_temp_k=$(echo "$json" | jq -r '.main.temp')
main_feels_like_k=$(echo "$json" | jq -r '.main.feels_like')
main_humidity=$(echo "$json" | jq -r '.main.humidity')

temp_c=$(echo "$main_temp_k-273.15" | bc)
feels_like_c=$(echo "$main_feels_like_k-273.15" | bc)

# echo "temperatur in Celsius"
# echo $temp_c
# echo " " 

# if (( $(echo "$temp_c < 0" | bc -l) )); then
#   echo "Die Temperatur ist unter 0°C" | mail -s "Temperaturalarm" arian.shkodra@edu.tbz.ch
# fi

echo "Test Inhalt text" | mail -s "Test Betreff Mail" arian.shkodra@edu.tbz.ch

