#!/usr/bin/env ruby
# Deploy the specified jars to AWS

# include the "lib" directory
File.expand_path(File.join(__dir__, "lib")).tap {|pwd|
  $LOAD_PATH.unshift(pwd) unless $LOAD_PATH.include?(pwd)
}

# Requires
###########
require 'deploy/aws/lambda'
require 'deploy/promote'

include Promote

options = parse(ARGV)
# get the function from the name
type = options.function.capitalize
name = options.function

function = Defintions[type].select{|definition|
  definition.name == name
}

lambda = LambdaAws.new(options)
lambda.promote(function, options.stage)
