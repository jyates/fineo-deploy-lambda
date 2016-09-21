#!/usr/bin/env bash
set -e
set -x

Ingest_Source_Dir=$WORKSPACE/jars
Schema_Source_Dir=$WORKSPACE/jars
Batch_Processing_Parent_Dir=$WORKSPACE/jars

current="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $current/.rvmrc
input=${current}/input.json
output=${current}/built.json
update=${current}/update.json

$current/setup-env.rb > ${input}

cmd="${current}/build-jar.rb --source ${input} --output ${output} -v"
if [ ! -z ${Dry_Run} ]; then
  cmd="${cmd} --dry-run"
fi

if [ ! -z ${Testing} ]; then
  cmd="${cmd} --testing"
fi

# run the build command
$cmd

if [ ! -z ${Dry_Run} ]; then
  exit 0
fi

cmd="${current}/deploy-lambda.rb --source ${output} --output ${update} \
--credentials ${CREDENTIALS} -v"
$cmd

echo
echo "------ Updated jars ------"
cat ${update}

exit 0
