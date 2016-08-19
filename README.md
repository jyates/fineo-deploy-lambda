# Deploy

Ruby scripts to enable easy deployment of the ingest modules. Each major component is broken out
into a set of deployable artifacts. Currently, no guarantees are made around idempotency, so
use *with caution*

## Requirements

RVM - the ruby version manager

## Running
### 1. Setup Environment (first time only)

```cd```ing into the directory should cause rvm to install any necessary dependencies.

### 2. Input Properties

Input properties are a simple hash of source/type. see ```example/input.json``` for how to define this. For CI, we also have the ```setup-env.rb``` script to translate environment variables to input json properties

### 3. Build Deployable Jar(s)

```$ build-jar.rb```

Builds the properties that each jar needs and then sets those properties in each of the desired deployment targets. Also allows you to 
override the properties with command line options.

An important property is the ```--testing [PREFIX]``` flag to enable a deployment of the functions with a testing prefix for prefixable properties (e.g firehose names, dynamo tables, etc).

### 3. Deploy jar to aws

```$ deploy-lambda.rb```

Does the actual deployment. Functions to deploy are determined by an input json file, the same as is output by ```build-jar.rb```. An example is avaible at ```example/output.json```. You can also just update the configuration of the lambda function via the ```--update-config-only``` flag. 
