#!/usr/bin/env bash

current=${PWD##*/}

input=${current}/input.json
output=${current}/output.json

./current/setup-env.sh > ${input}

cmd="./${current}/build-jar.rb --source ${input} --output ${output} -v"
if [ ! -z ${Dry_Run} ]; then
  cmd="${cmd} --dry-run"
fi

if [ ! -z ${Testing} ]; then
  cmd="${cmd} --testing"
fi

# run the build command
$cmd

echo "Updated files:"
cat ${output}

if [ ! -z ${Dry_Run} ]; then
  exit 0
fi

cmd="./${current}/deploy-lambda.rb --source ${output} -v"
$cmd

exit 0
