require 'rspec/core'
require "saki/ext/rspec_extensions"
require 'saki/request_helpers'
require 'saki/general_helpers'
require 'saki/restful_pathway_helpers'

RSpec.configuration.include Saki::GeneralHelpers
RSpec.configuration.include Saki::RequestHelpers, :type => :request
RSpec.configuration.include Saki::RestfulPathwayHelpers, :type => :request
