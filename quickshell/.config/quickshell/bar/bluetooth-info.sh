#!/bin/bash
if ! command -v bluetoothctl &>/dev/null; then
  echo '{"available":false,"powered":false,"devices":[]}'
  exit 0
fi

powered=$(bluetoothctl show 2>/dev/null | grep "Powered:" | awk '{print $2}')
if [ "$powered" != "yes" ]; then
  echo '{"available":true,"powered":false,"devices":[]}'
  exit 0
fi

echo -n '{"available":true,"powered":true,"devices":['
first=true
while IFS= read -r line; do
  [ -z "$line" ] && continue
  mac=$(echo "$line" | awk '{print $2}')
  name=$(echo "$line" | cut -d' ' -f3-)
  connected_str=$(bluetoothctl info "$mac" 2>/dev/null | grep "Connected:" | awk '{print $2}')
  if [ "$connected_str" = "yes" ]; then connected=true; else connected=false; fi
  if [ "$first" = true ]; then first=false; else echo -n ','; fi
  echo -n "{\"address\":\"$mac\",\"name\":\"$name\",\"connected\":$connected}"
done < <(bluetoothctl devices 2>/dev/null)
echo ']}'
