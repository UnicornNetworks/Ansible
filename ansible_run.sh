#!/bin/sh

NETWORK=$(ansible localhost -m setup -a "filter=ansible_default_ipv4" | grep "network" | awk '{print $NF}' | tr -d '",')
KNOWN_HOSTS="$HOME/.ssh/known_hosts"
TMPHOSTS=$(mktemp)

if [ -z "$NETWORK" ]; then
  echo "Missing network."
  exit 1
elif [ -z "$KNOWN_HOSTS" -o ! -f "$KNOWN_HOSTS" ]; then
  echo "Verify the KNOWN_HOSTS file."
fi

for host in $(egrep -v '#|\[' /etc/ansible/hosts | awk '{print $1}' | uniq); do
  ssh-keyscan -H "$host" >> "$TMPHOSTS"
done

sort "$TMPHOSTS" | uniq > "$KNOWN_HOSTS"
rm "$TMPHOSTS"

ansible-playbook site.yml --extra-vars "sshd_admin_net=$NETWORK/24" -K
