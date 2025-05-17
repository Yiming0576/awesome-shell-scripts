#!/bin/bash

# author: Yiming
# date: 2025-05-15
# version: 1.0


# Script to check the HTTP status of websites.

check_website() {
  local url=$1
  local status_code
  local result

  # Use curl to get the HTTP status code
  # -s: silent mode
  # -o /dev/null: discard output body
  # -w "%{http_code}": write out the HTTP status code
  # --connect-timeout 5: max time in seconds for connection
  # --max-time 10: max total time in seconds for the operation
  status_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 --max-time 10 "$url")

  if [ $? -ne 0 ]; then
    result="ERROR (Could not connect or timeout)"
  elif [[ "$status_code" -ge 200 && "$status_code" -lt 300 ]]; then
    result="ONLINE (Status: $status_code)"
  elif [[ "$status_code" -ge 300 && "$status_code" -lt 400 ]]; then
    result="REDIRECT (Status: $status_code)"
  elif [[ "$status_code" -ge 400 && "$status_code" -lt 500 ]]; then
    result="CLIENT ERROR (Status: $status_code)"
  elif [[ "$status_code" -ge 500 && "$status_code" -lt 600 ]]; then
    result="SERVER ERROR (Status: $status_code)"
  else
    result="UNKNOWN (Status: $status_code)"
  fi

  printf "%-40s -> %s\n" "$url" "$result"
}

if [ $# -eq 0 ]; then
  echo "Usage: $0 <url1> [url2] [url3] ..."
  echo "Example: $0 http://google.com https://api.example.com http://nonexistentwebsite.xyz"
  exit 1
fi

echo "Checking website statuses..."
echo "------------------------------------------------------"

for site_url in "$@"; do
  # Basic check if URL seems to start with http(s)://
  if [[ ! "$site_url" =~ ^https?:// ]]; then
    echo "Warning: '$site_url' does not look like a valid URL (missing http:// or https://). Prepending http://."
    site_url="http://$site_url"
  fi
  check_website "$site_url"
done

echo "------------------------------------------------------"
echo "Checks complete."

exit 0

