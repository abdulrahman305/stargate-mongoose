#!/bin/sh

# Default to INFO as root log level
LOGLEVEL=INFO
REQUESTLOG=false

while getopts "qr:t:j:" opt; do
  case $opt in
    q)
      REQUESTLOG=true
      ;;
    r)
      LOGLEVEL=$OPTARG
      ;;
    t)
      SGTAG=$OPTARG
      ;;
    j)
      JSONTAG=$OPTARG
      ;;
    \?)
      echo "Valid options:"
      echo "  -t <tag> - use Docker images tagged with specified Stargate version (will pull images from Docker Hub if needed)"
      echo "  -j <tag> - use Docker images tagged with specified JSON API version (will pull images from Docker Hub if needed)"
      echo "  -q - enable request logging for APIs in 'io.quarkus.http.access-log' (default: disabled)"
      echo "  -r - specify root log level for APIs (defaults to INFO); usually DEBUG, WARN or ERROR"
      exit 1
      ;;
  esac
done

. ./api-compatibility.versions
SGTAG=$stargate_version
JSONTAG=$json_api_version

if [ -z "$SGTAG" ]
then
  echo "Missing stargate version (option -t). For example -t v2.0.8"
  exit 1
fi

if [ -z "$JSONTAG" ]
then
  echo "Missing JSON API version (option -j). For example -j v1.0.0-ALPHA-1"
  exit 1
fi

export LOGLEVEL
export REQUESTLOG
export SGTAG
export JSONTAG

echo "Running with Stargate $SGTAG, JSON API $JSONTAG"

docker-compose -f bin/docker-compose.yml up -d
