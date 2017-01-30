#!/usr/bin/env ruby

# Property information about the internal apis (e.g. creating a tenant)
class Properties::Stripe < Properties::Property

  def self.key()
    return Properties::Stripe.new().withStripeKey()
  end

  def withStripeKey
    @opts << ArgOpts.source("mgmt.stripe.key",
      "-- NO Stripe Key SPECIFIED --",
      "stripe.apikey",
      "Access key for stripe API", true)
    self
  end
end
