require File.dirname(__FILE__) + "/../spec_helper"

<%- if driver == 'webrat' %>
require "webrat"

Webrat.configure do |config|
config.mode = :rack
end

module Saki::Webrat
include Rack::Test::Methods
include Webrat::Methods
include Webrat::Matchers
def app
Rails.application
end
end

RSpec.configuration.include Saki::Webrat, :type => :request

<%- else -%>
require 'capybara/rails'

RSpec.configuration.include Capybara, :type => :request
<%- end -%>

# Put your request spec helpers inside /spec/request/support
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}