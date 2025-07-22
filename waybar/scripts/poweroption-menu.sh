#!/bin/bash
profile=$(echo -e "Balanced\nPower Saver\nHigh Performance" | dmenu -p "Select Power Profile:")
case "$profile" in
    "Balanced") powerprofilesctl set balanced ;;
    "Power Saver") powerprofilesctl set power-saver ;;
    "High Performance") powerprofilesctl set high-performance ;;
    *) echo "Invalid option" ;;
esac
