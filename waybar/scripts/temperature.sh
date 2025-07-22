#!/bin/bash

cpu_temp=""
tooltip=""
temperature_raw=0

# Durchlaufe alle hwmon-Verzeichnisse und überprüfe die Temperaturdateien
for hwmon in /sys/class/hwmon/hwmon*; do
  # Name des Sensors (z.B. "coretemp")
  name=$(cat "$hwmon/name" 2>/dev/null)
  i=1
  while [ -f "$hwmon/temp${i}_input" ]; do
    # Lese die Temperaturdatei
    temp=$(cat "$hwmon/temp${i}_input" 2>/dev/null)
    
    # Überprüfe, ob die Temperaturdatei existiert und gültig ist
    if [ -z "$temp" ]; then
      # Falls keine Temperatur vorhanden ist, überspringen
      ((i++))
      continue
    fi
    
    # Konvertiere die Temperatur in Celsius
    temp_c=$((temp / 1000))  # Ganzzahlige Division anstelle von bc
    label_file="$hwmon/temp${i}_label"

    # Falls es eine Bezeichnung für den Sensor gibt, verwende diese, andernfalls Standard
    if [ -f "$label_file" ]; then
      label=$(cat "$label_file")
    else
      label="temp${i}"
    fi

    # CPU Gesamt-Temperatur (Package id 0)
    if [[ "$name" == "coretemp" && "$label" == "Package id 0" ]]; then
      cpu_temp="${temp_c}°C"
      temperature_raw=$temp
      tooltip+="CPU Overall: ${temp_c}°C\n"
    elif [[ "$name" == "coretemp" && "$label" =~ Core.* ]]; then
      # Überspringe Core-spezifische Temperaturen
      :
    else
      tooltip+="$name/$label: ${temp_c}°C\n"
    fi

    ((i++))
  done
done

# Wenn keine CPU-Temperatur gefunden wurde, setze "N/A"
if [ -z "$cpu_temp" ]; then
  cpu_temp="N/A"
fi

# Bestimme die Farbe der Klasse basierend auf der Temperatur
temp_celsius=$((temperature_raw / 1000))
color_class="normal"

if (( temp_celsius >= 85 )); then
  color_class="critical"
elif (( temp_celsius >= 70 )); then
  color_class="warning"
fi

# Ausgabe im JSON-Format für Waybar
echo -n "{\"text\": \" $cpu_temp\", \"tooltip\": \"${tooltip%\\n}\", \"class\": \"$color_class\"}"
