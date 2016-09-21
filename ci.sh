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

$current/setup-env.rb > ${input}

cmd="${current}/build-jar.rb --vv --properties-dir $WORKSPACE/properties/ --source ${input} --output ${output} -v"
if [ "true" = "${Dry_Run}" ]; then
  cmd="${cmd} --dry-run"
fi

if [ "true" = "${Testing}" ]; then
  cmd="${cmd} --testing"
fi

# run the build command
$cmd

if [ "true" = "${Dry_Run}" ]; then
  exit 0
fi

cmd="${current}/deploy-lambda.rb --vv --source ${output} --output ${update} \
--credentials ${CREDENTIALS} -v"
$cmd

echo
echo "------ Updated jars ------"
cat ${update}

exit 0
