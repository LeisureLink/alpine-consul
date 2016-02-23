#!/bin/sh

set -e && [ ! -z $DEBUG ] && set -x

usage() {
  cat <<EOT
Service discovery helper; looks up service locations via DNS.

In order to ease scripting, disco emits a non-zero exit code when a
lookup does not resolve the name provided.

Usage: disco <service> [OPTIONS]

OPTIONS:

  -n   Indicates the result should be the DNS name of the server
       rather than its IP address.

  -p   Discovers a service's listening port. This option only works
       when a service is registered with DNS with a SRV record.

  -h   Prints the command's usage.

EXAMPLES:

  > disco my.service
  12.345.678.9

  > disco -n my.service
  app-server-99.mydomain.local

  > disco -p my.service
  37909

EOT
}

# Initially, flags are unset.
n=0
p=0

for i in "$@" ; do
case $i in
  -n)
    n=1
    ;;
  -p)
    p=1
    ;;
  -h|--help)
    usage && exit 0
    ;;
  *)
    if [ -z $services ] ; then
      services=$i
    else
      services="$services $i"
    fi
    ;;
esac
done

disco() {
  local service=$1
  [ -z $service ] &&
    printf 'ERROR - argument 1, service name, is required.' >&2 && \
    exit 99

  # always use the first nameserver from resolv.conf, since drill seems to rotate through them for some reason
  local desired_ns=$(cat /etc/resolv.conf | grep nameserver | cut -d' ' -f2 | head -1)

  if [ $n -eq 1 ]; then
    name=$(drill @$desired_ns $service SRV | grep ^$service | awk '{print $8}' | sed 's/\.$//g')
    [ -z $name ] && exit 1
    printf '%s\n' $name && exit 0
  fi

  if [ $p -eq 1 ]; then
    port=$(drill @$desired_ns $service SRV | grep ^$service | awk '{print $7}')
    [ -z $port ] && exit 1
    printf '%s\n' $port && exit 0
  fi

  location=$(drill @$desired_ns $service | grep ^$service | awk '{print $5}')
  [ -z $location ] && exit 1
  printf '%s\n' $location && exit 0
}

for svc in $services; do
  disco $svc || (printf 'Service not found: %s\n' $svc >&2 && exit 1)
done
