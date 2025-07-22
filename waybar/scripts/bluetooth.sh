#!/bin/bash

# Funktion: Bluetooth-Status und verbundene Geräte anzeigen
status() {
    if bluetoothctl show | grep -q "Powered: yes"; then
        STATUS=" ON"
    else
        STATUS=" OFF"
    fi
    CONNECTED=$(bluetoothctl devices Connected | awk '{for(i=3;i<=NF;i++) printf "%s%s", $i, (i<NF ? " " : ""); print ""}' | paste -sd "," -)
    [ -z "$CONNECTED" ] && echo "$STATUS" || echo "$STATUS ($CONNECTED)"
}

# Funktion: Tooltip
tooltip() {
    if bluetoothctl show | grep -q "Powered: yes"; then
        STATUS="On"
    else
        STATUS="Off"
    fi
    CONNECTED=$(bluetoothctl devices Connected | awk '{for(i=3;i<=NF;i++) printf "%s%s", $i, (i<NF ? " " : ""); print ""}' | paste -sd ", " -)
    [ -z "$CONNECTED" ] && echo "Bluetooth: $STATUS" || echo "Bluetooth: $STATUS\nConnected: $CONNECTED"
}

# Funktion: Geräteliste anzeigen und verbinden (für Linksklick)
connect() {
    # Bluetooth einschalten, falls aus
    if ! bluetoothctl show | grep -q "Powered: yes"; then
        bluetoothctl power on
        sleep 1
    fi

    # Geräte scannen
    bluetoothctl scan on >/dev/null 2>&1
    sleep 3
    bluetoothctl scan off >/dev/null 2>&1

    # Verfügbare Geräte auflisten (MAC und Name)
    DEVICES=$(bluetoothctl devices | awk '{print $2 "\t" substr($0, index($0,$3))}')
    if [ -z "$DEVICES" ]; then
        notify-send "Bluetooth" "Keine Geräte gefunden"
        exit 1
    fi

    # Rofi-Menü anzeigen (nur Namen anzeigen, MAC-Adresse intern behalten)
    SELECTED=$(echo "$DEVICES" | awk '{print substr($0, index($0,$2))}' | rofi -dmenu -i -p "Bluetooth-Geräte verbinden:" -width 30)
    if [ -n "$SELECTED" ]; then
        # MAC-Adresse des ausgewählten Geräts finden
        MAC=$(echo "$DEVICES" | grep "$SELECTED" | awk '{print $1}')
        if [ -n "$MAC" ]; then
            if bluetoothctl connect "$MAC"; then
                notify-send "Bluetooth" "Verbunden mit $SELECTED"
            else
                notify-send "Bluetooth" "Verbindung fehlgeschlagen"
            fi
        else
            notify-send "Bluetooth" "Gerät nicht gefunden"
        fi
    fi
}

# Funktion: Bluetooth ein/aus schalten (für Rechtsklick)
toggle() {
    if bluetoothctl show | grep -q "Powered: yes"; then
        bluetoothctl power off
        notify-send "Bluetooth" "Bluetooth ausgeschaltet"
    else
        bluetoothctl power on
        notify-send "Bluetooth" "Bluetooth eingeschaltet"
    fi
}

# Aktion basierend auf Argument
case "$1" in
    "status")
        status
        ;;
    "tooltip")
        tooltip
        ;;
    "connect")
        connect
        ;;
    "toggle")
        toggle
        ;;
    *)
        status
        ;;
esac
