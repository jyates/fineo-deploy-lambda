#!/usr/bin/env ruby

class Properties::BatchProcessor

  def self.addProps(manager)
     manager.add(
      ArgOpts.new("batch.errors.dir", "== ERRORS ==", ->(props){
        errors = props["batch"]["errors"]
        raise "batch.errors configuration not specified. Batch props: #{props['batch']}'" if errors.nil?
        s3 = errors["s3"]
        bucket = s3["bucket"]
        prefix = s3["prefix"]
        return "s3://#{File.join(bucket, prefix)}"
      }))
  end
end
