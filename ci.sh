#!/usr/bin/env bash
set -e
set -x
current="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $current/.rvmrc
input=${current}/input.json
output=${current}/built.json
update=${current}/update.json

export Ingest_Source_Dir=$WORKSPACE/jars
export Schema_Source_Dir=$WORKSPACE/jars
export Batch_Processing_Parent_Dir=$WORKSPACE/jars

if [ "true" = "$Deploy_All" ]; then
  DEPLOY_ALL_FLAG="--deploy-all"
fi

$current/setup-env.rb $DEPLOY_ALL_FLAG > ${input}

cmd="${current}/build-jar.rb --vv --properties-dir $PROPS_DIR --source ${input} --output ${output}"
if [ "true" = "${Dry_Run}" ]; then
  cmd="${cmd} --dry-run"
fi

if [ "true" = "${Testing}" ]; then
  cmd="${cmd} --test"
fi

# run the build command
$cmd

if [ "true" = "${Dry_Run}" ]; then
  exit 0
fi

if [ "x" != "${CREDENTIALS}x" ]; then
  CREDS_PARAM="--credentials ${CREDENTIALS}"
fi

cmd="${current}/deploy-lambda.rb --vv \
  --source ${output} \
  --output ${update}  \
  ${CREDS_PARAM}
  -v"


if [ "true" = "${Testing}" ]; then
  cmd="${cmd} --test $PROPS_DIR"
fi

$cmd

echo
echo "------ Updated jars ------"
cat ${update}

exit 0
