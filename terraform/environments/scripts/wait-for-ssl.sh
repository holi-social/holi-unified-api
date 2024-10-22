#!/usr/bin/env sh
set -eu

# needs to start with https:// for this script to work, of course
url="$1"

# google has a cdn answering on requests. This cdn takes a while to be fully updated.
# Therefore, we don't return on first success, but on a number of consecutive successes.
number_of_consecutive_successful_tries_needed=10
number_of_consecutive_successful_tries_achieved=0

printf "Checking if SSL certificate for '%s' is installed: " "$url"

# storage for the return value of the curl command
retval=0

# shellcheck disable=SC2034
for i in $(seq 1 2500); do
  set +e
  out=$(curl -sSLI "$url" 2>&1)
  retval=$?
  set -e
  # shellcheck disable=SC2181
  if [ "$retval" -eq "0" ]; then
    number_of_consecutive_successful_tries_achieved=$((number_of_consecutive_successful_tries_achieved + 1))
    echo "Success (${number_of_consecutive_successful_tries_achieved})"
    if [ "$number_of_consecutive_successful_tries_achieved" -eq "$number_of_consecutive_successful_tries_needed" ]; then
      echo "Test successful after $i total tries"
      exit 0
    fi
  else
    printf "."
    number_of_consecutive_successful_tries_achieved=0
    sleep 1
  fi
done

printf "No success after %s tries. Last output was:\n%s\n" "$i" "$out"
exit 1
