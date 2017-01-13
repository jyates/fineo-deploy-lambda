#!/usr/bin/env ruby

class Properties::Iam

  attr_reader :opts
  def initialize()
    @opts = []
  end

  def withDeviceKeyMgmt
    @opts << ArgOpts.source("mgmt.device.group.name", "--NO Group Loaded In Prop Gen",
                            "iam.devices.group.name", "IAM group to use for device access")
    self
  end

  def addProps(manager)
    manager.addAll(@opts)
  end

private
end
