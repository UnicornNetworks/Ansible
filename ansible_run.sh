#!/bin/sh

NETWORK=$(ansible localhost -m setup -a "filter=ansible_default_ipv4" | grep "network" | awk '{print $NF}' | tr -d '",')
KNOWN_HOSTS="$HOME/.ssh/known_hosts"
TMPHOSTS=$(mktemp)

if [ -z "$NETWORK" ]; then
  echo "Missing network."
  exit 1
elif [ -z "$KNOWN_HOSTS" ] || [ ! -f "$KNOWN_HOSTS" ]; then
  echo "Verify the KNOWN_HOSTS file."
fi

if ! find ./ -type f -name '*.y*ml' ! -name '.*' -print0 | \
  xargs -0 ansible-lint -x 403 -x 204; then
    echo 'ansible-lint failed.'
    exit 1
fi

if ! find ./ -type f -name '*.y*ml' ! -name '.*' -print0 | \
  xargs -0 yamllint -d "{extends: default, rules: {line-length: {level: warning}}}"; then
    echo 'yamllint failed.'
    exit 1
fi

for host in $(grep -E -v '#|\[' /etc/ansible/hosts | awk '{print $1}' | uniq); do
  ssh-keyscan -H "$host" >> "$TMPHOSTS"
done

sort "$TMPHOSTS" | uniq > "$KNOWN_HOSTS"
rm "$TMPHOSTS"

ansible-playbook all.yml --extra-vars "sshd_admin_net=$NETWORK/24" -K
