#! /bin/bash

LOOP_INTERVAL=3

PLUGIN_LEVEL=25
DANGER_LEVEL=15
SUSPEND_LEVEL=5

while [[ true ]]; do
	if [[ -n $(acpi -b | grep Charging) ]]; then
		continue
	fi

	battery_level=$(acpi -b | grep -Eo "[0-9]+%" | grep -Eo "[0-9]+")
        battery_percent=$(acpi -b | grep -Eo "[0-9]+%")

	if [[ $battery_level -gt $PLUGIN_LEVEL ]]; then
		LOOP_INTERVAL=8
	else
		LOOP_INTERVAL=3
		notification_msg=""
		if [[ $battery_level -le $SUSPEND_LEVEL ]]; then
			notification_msg="Battery level: $battery_percent, at CRITICAL levels. Please plugin to a power source"
		elif [[ $battery_level -le $DANGER_LEVEL ]]; then
			notification_msg="Battery level: $battery_percent, at dangerous levels. Please plugin to a power source"
		elif [[ $battery_level -le $PLUGIN_LEVEL ]]; then
			notification_msg="Battery level: $battery_percent, below plugin levels. Please plugin to a power source"
		fi
		if [[ -n $notification_msg ]]; then
			/usr/bin/notify-send "Power notifier" "$notification_msg"
		fi
	fi
	sleep ${LOOP_INTERVAL}m
done
