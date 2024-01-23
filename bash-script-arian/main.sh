#!/bin/bash

# Autor: Arian Shkodra
# Datum: 23.01.2024
# Version: 1.0
#
# Beschreibung:
# Die WeatherApp ruft Wetterdaten von Zürich mithilfe der OpenWeatherMap API ab. Diese API sendet
# die Daten im JSON-Format, und die verschiedenen Informationen werden in Variablen gespeichert. 
# Einige Daten werden umgerechnet, von Kelvin in Grad Celsius. Anschließend werden die Temperaturen 
# überprüft. Wenn es kälter als 10 Grad Celsius ist, wird eine Warnung per E-Mail versendet, dass heute
# kaltes Wetter zu erwarten ist. Im Falle von Temperaturen über 18 Grad Celsius wird ebenfalls eine 
# Warnung per E-Mail versendet, dass es heute warm sein wird. Alle angegebenen Wetterdaten sowie der 
# Standort, in diesem Fall Zürich, werden in einer Datenbank gespeichert.

# Abrufen der Wetterdaten von Zürich mithilfe der OpenWeatherMap API im JSON-Format.
# In der API kann man den Standort angeben, von dem man die Wetterdaten haben möchte. 
# Dies kann man an der Stelle "lat=47.36&lon=8.55" tun, indem man die Koordinaten eines Ortes angibt."
API_json=$(curl -s 'https://api.openweathermap.org/data/2.5/weather?lat=47.36&lon=8.55&appid=a889fa2bffa32a36daedfe34e5f7c7e8')

# Überprüfen Sie, ob die API erreichbar ist
# $? -ne 0 ist ein Standart Unix Command der kontrolliert ob das letze Kommando funktioniert hat.
if [ $? -ne 0 ]; then
    echo "Fehler: API ist nicht erreichbar" >&2
    exit 1
fi
 

# Extrahieren der Daten aus dem JSON-response in verschiedene Variablen
name=$(echo "$API_json" | jq -r '.name')
weather_description=$(echo "$API_json" | jq -r '.weather[0].description')
visibility=$(echo "$API_json" | jq -r '.visibility')
wind_speed=$(echo "$API_json" | jq -r '.wind.speed')
main_humidity=$(echo "$API_json" | jq -r '.main.humidity')
main_temp_k=$(echo "$API_json" | jq -r '.main.temp')
main_feels_like_k=$(echo "$API_json" | jq -r '.main.feels_like')

# Umrechnen von Kelvin in Grad Celsius
temp_c=$(echo "$main_temp_k-273.15" | bc)
feels_like_c=$(echo "$main_feels_like_k-273.15" | bc)

# Datenbankverbindungsinformationen
db_host="172.16.17.160"
# db_host="ke.internet-box.ch:2206"
db_user="user02"
db_pass="MaSq-02"
db_name="weather-app-milari"
db_table_name="WeatherApp"

# Erstellen des SQL-Befehls zum Einfügen der Wetterdaten in die Datenbank
sql="INSERT INTO ${db_table_name} (name, weather_description, visibility, wind_speed, main_humidity, temp_c, feels_like_c) VALUES ('${name}', '${weather_description}', '${visibility}', '${wind_speed}', '${main_humidity}', '${temp_c}', '${feels_like_c}')"

# Ausführen des SQL-Befehls in der MySQL-Datenbank
mysql -h $db_host -u $db_user -p$db_pass $db_name -e "$sql"

# Überprüfen Sie, ob die Datenbank erreichbar ist
if [ $? -ne 0 ]; then
    echo "Fehler: Datenbank ist nicht erreichbar" >&2
    exit 1
fi

# Überprüfen der Temperatur und Senden einer E-Mail-Warnung bei warmem oder kaltem Wetter. 
# Die E-Mails werden mithilfe von ssmtp und mailutils versendet.
if (( $(echo "$temp_c > 18" | bc -l) )); then
    mail -s 'ACHTUNG: Warmes Wetter' -a From:\<arian89sh08@smart-mail.de\> arian.shkodra@edu.tbz.ch <<< "Es ist ${temp_c} C, gefuehlt wird es: ${feels_like_c} C, Sichtbarkei: ${visibility} m, Wind: ${wind_speed} m/s, Feuchtigkeit: ${main_huminity}%, Wetter beschreibung: ${weather_description}"
elif (( $(echo "$temp_c < 10" | bc -l) )); then
    mail -s 'ACHTUNG: Kaltes Wetter' -a From:\<arian89sh08@smart-mail.de\> arian.shkodra@edu.tbz.ch <<< "Es ist ${temp_c} C, gefuehlt wird es: ${feels_like_c} C, Sichtbarkei: ${visibility} m, Wind: ${wind_speed} m/s, Feuchtigkeit: ${main_huminity}%, Wetter beschreibung: ${weather_description}"
fi 
 