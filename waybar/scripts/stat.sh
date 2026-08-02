#!/usr/bin/env bash
# Small system readouts for panels that exec a command rather than shelling out.
#
# nwg-panel's `executor` runs its `script` directly, not through a shell, so an
# inline `$(...)` is printed verbatim instead of being evaluated. Anything a
# panel needs to compute therefore has to live in a real executable like this.
#
# CPU is sampled from two reads of /proc/stat rather than `top -bn1`: top's
# first iteration reports the average since boot, which barely moves and is
# not what anyone means by "CPU right now".
#
# Usage: stat.sh cpu|mem|disk|temp

set -uo pipefail

cpu_pct() {
    read -r _ a b c d rest < /proc/stat
    local idle1=$d total1=$((a + b + c + d))
    sleep 0.3
    read -r _ a b c d rest < /proc/stat
    local idle2=$d total2=$((a + b + c + d))
    local dt=$((total2 - total1)) di=$((idle2 - idle1))
    [ "$dt" -gt 0 ] || { echo 0; return; }
    echo $(( (100 * (dt - di)) / dt ))
}

case "${1:-cpu}" in
    cpu)  printf 'cpu %s%%\n' "$(cpu_pct)" ;;
    mem)  awk '/MemTotal/{t=$2} /MemAvailable/{a=$2}
               END{printf "mem %d%%\n", (t-a)*100/t}' /proc/meminfo ;;
    disk) df -h --output=pcent / | tail -1 | tr -d ' %' \
            | awk '{printf "disk %s%%\n", $1}' ;;
    temp) for z in /sys/class/thermal/thermal_zone*/temp; do
              [ -r "$z" ] || continue
              awk '{printf "temp %d°C\n", $1/1000}' "$z"; return 2>/dev/null || exit 0
          done
          echo "temp --" ;;
    *)    echo "usage: stat.sh cpu|mem|disk|temp" >&2; exit 2 ;;
esac
