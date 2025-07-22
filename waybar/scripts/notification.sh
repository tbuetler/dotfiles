#!/bin/bash

# Anzahl der offenen Benachrichtigungen
COUNT=$(dunstctl count waiting 2>/dev/null || echo 0)

# Ausgabe für Waybar
if [ "$COUNT" -eq 0 ]; then
    echo " 0"
else
    echo " $COUNT"
fi
