#!/bin/bash

# Autor: Milos Milosevic
# Datum: 23.01.2024
# Version: 1.1
# Beschreibung: 
# Bash script das sich Daten in Form eines JSOn Array's von einem API Provider hollt und diese in eine          
# mysql Datenbank einfügt. Im Script werden auch die nötigen Passwörter sowie Nutzernamen für das Login       
# gespeichert. Mit dem tool jq wird das konvertieren der JSON Daten in ein passendes Datenbank Format ermöglicht.
# In meiner Doku finden Sie mehr zum jq tool. 






# API Call von Provider
# Provider: https://openweathermap.org/
API_KEY="a889fa2bffa32a36daedfe34e5f7c7e8"
response=$(curl -s "https://api.openweathermap.org/data/2.5/weather?lat=47.55&lon=7.58&appid=${API_KEY}")
 
# JSON Array konvertieren und Output abrufen
name=$(echo $response | jq -r '.name')
weather_description=$(echo $response | jq -r '.weather[0].description')
visibility=$(echo $response | jq -r '.visibility')
wind_speed=$(echo $response | jq -r '.wind.speed')
main_humidity=$(echo $response | jq -r '.main.humidity')

# Zwei Werte die noch umgewandelt werden müssen. 
temp_k=$(echo "$response" | jq -r '.main.temp')
feels_like_k=$(echo "$response" | jq -r '.main.feels_like')
 
# API gibt diese zwei Werte in Kelvin an. Mithilfe des bc Konverters werden diese auf Celcius umgewandelt. 
temp_c=$(echo "$temp_k-273.15" | bc)
feels_like_c=$(echo "$feels_like_k-273.15" | bc)

# SQL query um Daten in die Datenbank "WeatherApp" einzufügen.
sql_code="INSERT INTO WeatherApp (name, weather_description, visibility, wind_speed, main_humidity, temp_c, feels_like_c) VALUES ('${name}', '${weather_description}', '${visibility}', '${wind_speed}', '${main_humidity}', '${temp_c}', '${feels_like_c}')"

# MYSQL Daten für die Verbindung
# mysql -u user02 -p -D weather-app-milari -e "$sql" db_host="ke.internet-box.ch:2206"
db_host="172.16.17.160"
db_pass="MaSq-02"

# Abschliessender Login
mysql -h $db_host -u user02 -p$db_pass weather-app-milari -e "$sql_code"

# Email die gesendet wird bei extremen Wetter. Ich selbst konnte definieren was ich dazu verwende und wie kalt oder warm es werden muss um auf extrem eingestuft zu werden.
# Die Email musste eine sein die keine 2FA nutzt um das Login zu ermöglichen. 
# Dazu wird ssmpt und mail-utilities genutzt. Mehr info dazu in meiner Doku. 
if (( $(echo "$feels_like_c > 17" | bc -l) )); then
  mail -s 'WARNUNG: T-Shirt Wetter!!' -a From:\<milos52mil@smart-mail.de\> milos.milosevic@edu.tbz.ch <<< "Es ist ${temp_c} C, gefuehlt wird es: ${feels_like_c} C, Sichtbarkei: ${visibility} m, Wind: ${wind_speed} m/s, Feuchtigkeit: ${main_huminity}%, Wetter beschreibung: ${weather_description} Deswegen müssen sie sich keine Sorge machen und der Sommer kann starten!"
elif (( $(echo "$feels_like_c < 8" | bc -l) )); then
  mail -s 'WARNUNG: Gute Jacke anziehen!' -a From:\<milos52mil@smart-mail.de\> milos.milosevic@edu.tbz.ch <<< "Es ist ${temp_c} C, gefuehlt wird es: ${feels_like_c} C, Sichtbarkei: ${visibility} m, Wind: ${wind_speed} m/s, Feuchtigkeit: ${main_huminity}%, Wetter beschreibung: ${weather_description} Es wird sehr kalt, lieber zu Hause bleiben!"
fi
