#!/bin/bash
set -x

domain=""
network=""
ip=""
host=""
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
      host="$OPTARG"
      ;;
    *)
      usage
      ;;
  esac
done
shift $(expr $OPTIND - 1)

mac=$(virsh dumpxml ${domain} | grep "mac address" | cut -d\' -f2)

#echo $host $mac $ip $network

case $mode in
  add)
    virsh net-update ${network} ${mode} ip-dhcp-host --live --config \
      --xml "<host mac='${mac}' name='${domain}' ip='${ip}' />"
  ;;
  delete)
    virsh net-update ${network} ${mode} ip-dhcp-host --xml "<host ip='${ip}' />" --live --config
  ;;
esac
