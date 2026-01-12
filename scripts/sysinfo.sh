#!/bin/sh

OUT="/run/user/$UID/sysinfo"

read u1 t1 < <(awk 'NR==1{print $2+$4, $2+$4+$5}' /proc/stat)

charging_switch=true

while :; do
  sleep 1.2

  # CPU
  read u2 t2 < <(awk 'NR==1{print $2+$4, $2+$4+$5}' /proc/stat)
  CPU=$(( (u2-u1)*100/(t2-t1) ))
  u1=$u2
  t1=$t2

  # RAM (% only)
  RAM=$(awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END {printf "%d", (1-a/t)*100}' /proc/meminfo)

  # Battery (%)
  BAT=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n1)

  # Battery Icon	
  if [ "$( cat /sys/class/power_supply/BAT1/status)" = "Charging" ]; then
	  if [ "$BAT" -lt "75" ]; then
	  	if [ "$BAT" -lt "40" ]; then
	  		if [ "$BAT" -lt "15" ]; then
	  			bicon="󰢟 "
	  		else
	  			bicon="󱊤 "
	  		fi
	  	else
	  		bicon="󱊥 "
	  	fi
	  else
	  	bicon="󱊦 "
	  fi
  else
	  if [ "$BAT" -lt "75" ]; then
	  	if [ "$BAT" -lt "40" ]; then
	  		if [ "$BAT" -lt "15" ]; then
	  			bicon="󰂎"
	  		else
	  			bicon="󱊡"
	  		fi
	  	else
	  		bicon="󱊢"
	  	fi
	  else
	  	bicon="󱊣"
	  fi
  fi
  
  # Charging notification
  if [ "$( cat /sys/class/power_supply/BAT1/status)" = "Charging" ]; then
  	if [[ "$charging_switch" == true ]]; then
  		notify-send "Charging, "$BAT"%"$bicon"" -t 1800
  		charging_switch=false
  	fi
  else
  	charging_switch=true
  fi
  
  # Low charge notifications
  if [ $BAT -lt 8 ] && [ $BAT -lt $min ]; then
  	makoctl dismiss -n 0
  	notify-send "$BAT% 󰂎!"
  	min=$BAT
  else
  	min=$BAT
  fi

  # Time
  TIME=$(date "+%H:%M %a %d.%m")

  printf "%s   %d%%  %d%% $bicon%s%%""\n" \
    "$TIME" "$CPU" "$RAM" "${BAT:-?}" > "$OUT"
done
