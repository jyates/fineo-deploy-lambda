#!/usr/bin/env ruby

class Properties::LaunchEmr

  def self.addProps(manager)
     manager.add(
     ArgOpts.direct("batch.cluster.name", "batch-processing", 'Name of the cluster'),
     ArgOpts.direct("batch.cluster.main", "== MAIN CLASS ==", 'Main class to run in the batch cluster'),
     ArgOpts.direct("batch.cluster.s3.bucket", "deploy.fineo.io", "s3 bucket where the jar is stored"),
     ArgOpts.direct("batch.cluster.s3.key", "== KEY ==", "s3 patch where the jar is stored"))
  end
end
