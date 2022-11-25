#!/bin/bash

# This script helps to test the Hurl script against any environment
# First argument will be the environment (sandbox. dev, qa, prod)
# Second argument will be the name of the sandbox environment (sandbox only)
# Examples:
#   ./run.sh dev
#   ./run.sh sandbox mvg-1234
#   ./run.sh qa
#   ./run.sh prod
#
# Tests can be added for a specificy environment only adding the script on a folder with the same name of the environment.
# However, its better to have the same tests and be able to reproduce on multiple environment than have specific tests per environment
# Use with moderation only if really necessary
# Example:
# ./tests/dev/00-my-test.hurl  # this will only be executed on 'dev' environment

if [[ "$0" != *"/tests/"* ]]; then
  cd .. # always execute from the root folder of this project
fi

export ENV="$1"

if [[ "$ENV" == "" ]]; then
  echo "No environment passed. Pass the environment as first argument of this script"
  exit 1
fi

echo "Testing with environment '$ENV' "

export RELEASE_ENV_NAME="$(yq -r ".k8s.activeRelease // \"$2\"" ./environments/$ENV/values/_all.values.yaml)"
export HURL_EXTERNAL_HOSTNAME=$(yq -r '.mvg.publicAlias // .mvg.hostName' ./environments/$ENV/values/_all.values.yaml)
export HURL_INTERNAL_HOSTNAME=$(yq -r '.mvg.hostName' ./environments/$ENV/values/_all.values.yaml)
export HURL_PUBLIC_HOSTNAME=$(yq -r '.mvg.publicName // .mvg.hostName' ./environments/$ENV/values/_all.values.yaml)
export HURL_ACTIVE_HOSTNAME="$RELEASE_ENV_NAME-$HURL_INTERNAL_HOSTNAME"

echo "DEPLOYMENT_DIR=$DEPLOYMENT_DIR, RELEASE_ENV_NAME=$RELEASE_ENV_NAME, HURL_EXTERNAL_HOSTNAME=$HURL_EXTERNAL_HOSTNAME, HURL_INTERNAL_HOSTNAME=$HURL_INTERNAL_HOSTNAME, HURL_PUBLIC_HOSTNAME=$HURL_PUBLIC_HOSTNAME, HURL_ACTIVE_HOSTNAME=$HURL_ACTIVE_HOSTNAME"

hurl --test --glob "tests/default/**/*.hurl" --glob "tests/$ENV/**/*.hurl" --file-root .
#hurl tests/default/06-customer-test-with-image.hurl -v
#hurl --test tests/default/02-check-URLs.hurl -v
#hurl --test tests/default/03-config-server.hurl
#hurl tests/default/05-external-service.hurl
#hurl tests/default/07-roof-imagery.hurl
#hurl tests/default/08-roof-imagery-arturo-image.hurl
#hurl tests/default/10-external-service-with-roof-imagery-url.hurl
#hurl tests/default/11-external-service-without-roof-imagery-url.hurl