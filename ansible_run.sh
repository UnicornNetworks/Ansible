#!/bin/bash

NETWORK=$(ansible localhost -m setup -a "filter=ansible_default_ipv4" 2>/dev/null | grep "network" | awk '{print $NF}' | tr -d '",')
KNOWN_HOSTS="$HOME/.ssh/known_hosts"
TMPHOSTS=$(mktemp)
HOSTRESOLV=0
HOSTFILE="/etc/ansible/hosts"
IFS=$'\n'

if [ -z "$NETWORK" ]; then
  echo "Missing network."
  exit 1
elif [ -z "$KNOWN_HOSTS" ] || [ ! -f "$KNOWN_HOSTS" ]; then
  echo "Verify the $KNOWN_HOSTS file."
fi

if [ "$1" = "vagrant" ]; then
  if [ ! -f "./hosts" ] || [ "$2" = "hosts" ]; then
    echo "Generating Ansible hosts file using Vagrant."
    {
      echo "[vagrant]"
      for VM in $(vagrant status | grep -iE 'running.*virtualbox' | awk '{print $1}'); do
        mapfile -t VAGRANT_SSH < <(vagrant ssh-config "$VM" | awk '{print $NF}')
        echo "${VAGRANT_SSH[0]} ansible_host=${VAGRANT_SSH[1]} ansible_user=${VAGRANT_SSH[2]} ansible_port=${VAGRANT_SSH[3]} ansible_private_key_file=${VAGRANT_SSH[7]}"
        ssh-keygen -R "[${VAGRANT_SSH[1]}]:${VAGRANT_SSH[3]}" 2>/dev/null 1>&2
        ssh-keyscan -p"${VAGRANT_SSH[3]}" "${VAGRANT_SSH[1]}" >> "$KNOWN_HOSTS" 2>/dev/null
      done
    } > ./hosts
    HOSTFILE="./hosts"
  elif [ -f "./hosts" ]; then
    echo "./hosts file exists. Won't overwrite."
  else
    echo "vagrant hosts flag not set."
  fi

  if ! command -v vagrant 1>/dev/null; then
    exit 1
  fi

  if ! vagrant validate Vagrantfile; then
    exit 1
  fi
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

if [ -f /etc/ansible/hosts ] && [ "$1" != "vagrant" ]; then
  for host in $(grep -E -v '#|\[' /etc/ansible/hosts | awk '{print $1}' | uniq); do
    if dig +answer "$1" | grep -q 'status: NOERROR'; then
      ssh-keyscan -H "$host" >> "$TMPHOSTS"
    else
      echo "$host doesn't resolve, leaving $KNOWN_HOSTS untouched."
      HOSTRESOLV=1
    fi
  done

  if [ $HOSTRESOLV = 0 ]; then
    echo
    echo "Generating $KNOWN_HOSTS. Saving current to $KNOWN_HOSTS.bak"
    cp -v "$KNOWN_HOSTS" "$KNOWN_HOSTS.bak"
    sort "$TMPHOSTS" | uniq > "$KNOWN_HOSTS"
  fi
fi

rm "$TMPHOSTS"

ansible-playbook all.yml -i "$HOSTFILE" --extra-vars "sshd_admin_net=$NETWORK/24 sshd_max_auth_tries=6 ansible_python_interpreter=/usr/bin/python3" -K
