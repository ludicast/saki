require 'rspec/core'
require "saki/ext/rspec_extensions"
require 'saki/acceptance_helpers'
require 'saki/general_helpers'
require 'saki/restful_pathway_helpers'

RSpec.configuration.include Saki::GeneralHelpers
RSpec.configuration.include Saki::AcceptanceHelpers, :type => :acceptance
RSpec.configuration.include Saki::RestfulPathwayHelpers, :type => :acceptance