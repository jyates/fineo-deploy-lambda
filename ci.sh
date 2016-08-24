#!/usr/bin/env bash
set -e

current="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

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
