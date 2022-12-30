#!/bin/bash
set -e

echo "#################################################"
echo "> Starting ${GITHUB_WORKFLOW}:${GITHUB_ACTION}"

# Available env
# echo "INPUT_HOST: ${INPUT_HOST}"
# echo "INPUT_PORT: ${INPUT_PORT}"
# echo "INPUT_USER: ${INPUT_USER}"
# echo "INPUT_PASS: ${INPUT_PASS}"
# echo "INPUT_KEY: ${INPUT_KEY}"
# echo "INPUT_LOCAL: ${INPUT_LOCAL}"
# echo "INPUT_REMOTE: ${INPUT_REMOTE}"
# echo "INPUT_RUN_BEFORE: ${INPUT_RUNBEFORE}"
# echo "INPUT_RUN_AFTER: ${INPUT_RUNAFTER}"
# echo "INPUT_USE_RSYNC_URL: ${INPUT_USERSYNCURL}"

RUNBEFORE="${INPUT_RUNBEFORE/$'\n'/' && '}"
RUNAFTER="${INPUT_RUNAFTER/$'\n'/' && '}"

if [ -z "$INPUT_KEY" ]; then # Password
  echo "> Exporting Password"
  export SSHPASS=$PASS

  echo "> Deploying now"
  if [ -z "$USERSYNCURL" ]; then
    sshpass -p $INPUT_PASS rsync -avhz --progress --stats -e "ssh -p $INPUT_PORT" $GITHUB_WORKSPACE/$INPUT_LOCAL $INPUT_USER@$INPUT_HOST:$INPUT_REMOTE --delete-during
  else
    sshpass -p $INPUT_PASS rsync -avhz --progress --stats $GITHUB_WORKSPACE/$INPUT_LOCAL rsync://$INPUT_USER@$INPUT_HOST:$INPUT_PORT$INPUT_REMOTE --delete-during
  fi

else
  # Private key
  pwd
  mkdir "/root/.ssh"

  echo "$INPUT_KEY" >"/root/.ssh/id_rsa"
  chmod 400 "/root/.ssh/id_rsa"

  echo "Host *" >"/root/.ssh/config"
  echo "  AddKeysToAgent yes" >>"/root/.ssh/config"
  echo "  IdentityFile /root/.ssh/id_rsa" >>"/root/.ssh/config"

  cat "/root/.ssh/config"

  ls -lha "/root/.ssh/"

  echo "> Deploying now"
  if [ -z "$USERSYNCURL" ]; then
    sshpass -e rsync -avhz --progress --stats $GITHUB_WORKSPACE/$INPUT_LOCAL rsync://$INPUT_USER@$INPUT_HOST:$INPUT_PORT$INPUT_REMOTE --delete-during
  else
    sshpass -e rsync -avhz --progress --stats -e "ssh -p $INPUT_PORT" $GITHUB_WORKSPACE/$INPUT_LOCAL $INPUT_USER@$INPUT_HOST:$INPUT_REMOTE --delete-during
  fi
fi

echo "#################################################"
echo "Completed ${GITHUB_WORKFLOW}:${GITHUB_ACTION}"
