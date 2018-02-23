# How to use this script:
# source /scripts/create_service.sh   <service-name>  <image-tag>                       <environment>   <db-uri>
# source /scripts/create_service.sh   aws-qe-deploy   praqma/questionaire-engine:0.1.0  test            "mongodb://praqmadb:..."

# ATTENTION: the grep command requires the -P flag for regex to work on this CI server - might throw error on differenc linux versions

SERVICE_NAME=$1
IMAGE_TAG=$2
ENV=$3
DB_URI=$4


create_service() {
  echo "Creating service..."
  fargate service create $SERVICE_NAME --image praqma/questionnaire-engine:0.1.0 --env DB_URI=$DB_URI --env PORT=80
}

check_service_status() {
	fargate service info $SERVICE_NAME | grep -oP 'Running: \d' | grep -oP '\d'
}

get_ip() {
  fargate service info $SERVICE_NAME | grep -oG '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'
}

SECONDS=0
wait_for_ip() {
  if [ "$SERVICE_NAME" == "" ]; then
    echo "SERVICE_NAME not found. Did you source your env vars?"
  fi

  while [[ $RUNNING -ne "1" ]]
  do
    RUNNING=$(check_service_status)

    if [ "$RUNNING" == "1" ]; then
      echo "Server is running on IP $(get_ip)"
      break
    elif [ "$RUNNING" == "0" ]; then
      echo "[i] Server is pending. Will refresh in 5 seconds..."
    else
      echo "[!] Could not check service status."
    fi
    sleep 5s

    # time out after 5 minutes (300 seconds)
    if [ $SECONDS -gt "300" ]
    then
      echo "[!] Timed out - server could not be started."
      break
    fi
  done
}

create_service
wait_for_ip
export IP=$(get_ip)
