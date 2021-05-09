#!/bin/bash
set -x

domain=""
network=""
ip=""
hostgroup=""
mode=""

while getopts "d:n:m:i:h:" opt ; do
  case $opt in
    d)
      domain="$OPTARG"
      ;;
    m)
      mode="$OPTARG"
      ;;
    n)
      network="$OPTARG"
      ;;
    i)
      ip="$OPTARG"
      ;;
    h)
      hostgroup="$OPTARG"
      ;;
    *)
      usage
      ;;
  esac
done
shift $(expr $OPTIND - 1)
array=($(virsh domifaddr "${domain}" --source agent "eth0" | awk '/ipv4/ { gsub(/\/24/, ""); print $2,$4;}'))
name=${domain}
ip=${array[1]}
mac=$(virsh dumpxml ${domain} | grep "mac address" | cut -d\' -f2)
echo -e $mac
