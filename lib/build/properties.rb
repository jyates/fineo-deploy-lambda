
# Simple helper that just includes all the different source modules
Dir["#{__dir__}/properties/*.rb"].each { |f|
  require f
}
