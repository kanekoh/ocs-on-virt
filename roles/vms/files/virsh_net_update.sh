#!/bin/bash

network=""
domain=""

usage(){
cat <<EOF
usage: $(basename $0) -d DOMAIN -m MODE -n NETWORK

Update the given section of an existing network definition, with the changes optionally taking effect immediately, without needing to destroy and re-start the network.

General Options:
  -d      Set domain name of the virtual machine.
  -m      Set add or delete.
  -n      Set network name of the virtual network.
  -i      Set interface for specifying network.

EOF
exit 2
}

while getopts "d:n:m:i:h" opt ; do
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
      interface="$OPTARG"
      ;;
    h)
      usage
      ;;
    *)
      usage
      ;;
  esac
done
shift $(expr $OPTIND - 1)

update_network_obsolete(){
array=($(virsh net-dhcp-leases "${network}" | grep "${domain}" | awk '{ gsub(/\/24/, ""); print $6,$5,$3;}'))
name=${array[0]}
ip=${array[1]}
mac=${array[2]}
echo "  name=${name} ip=${ip} mac=${mac}"
}

update_network(){
array=($(virsh domifaddr "${domain}" --source agent "${interface}" | awk '/ipv4/ { gsub(/\/24/, ""); print $2,$4;}'))
mac=${array[0]}
ip=${array[1]}
echo "  name=${domain} mac=${mac} ip=${ip}"

virsh net-update ${network} ${mode} ip-dhcp-host --live --config \
--xml "<host mac='${mac}' name='${domain}' ip='${ip}' />"
}

[ -n "${network}" ] || usage
[ -n "${domain}" ] || usage
[ -n "${mode}" ] || usage
[ -n "${interface}" ] || usage

# begin script
update_network

