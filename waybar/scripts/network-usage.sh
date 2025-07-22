#!/bin/bash

INTERFACE="wlp0s20f3"  # Ändere das auf dein Netzwerkinterface

OLD_RX=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
OLD_TX=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)

sleep 1

NEW_RX=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
NEW_TX=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)

DOWN=$(( (NEW_RX - OLD_RX) / 1024 )) # in KB/s
UP=$(( (NEW_TX - OLD_TX) / 1024 ))   # in KB/s

echo "{\"down\": \"${DOWN}KB/s\", \"up\": \"${UP}KB/s\"}"
