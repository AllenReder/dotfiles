#!/usr/bin/env bash
set -euo pipefail

iface="$(ip -o -4 route show default 2>/dev/null | awk '{print $5; exit}')"

if [ -z "${iface}" ]; then
  # disconnected
  echo "󰤮"
  exit 0
fi

if [ -d "/sys/class/net/${iface}/wireless" ]; then
  # wifi
  echo "󰤨"
  exit 0
fi

# wired (default)
echo "󰈀"
