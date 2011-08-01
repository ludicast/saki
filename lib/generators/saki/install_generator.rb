require 'rails/generators'
RequestDir = "request"

module Saki
  class InstallGenerator < Rails::Generators::Base
    class_option :capybara, :desc => 'Use Capybara.', :type => :boolean

    source_root File.join(File.dirname(__FILE__), 'templates')

    desc <<-DESC
Description:
Sets up Saki in your Rails project. This will generate the
spec/request directory and the necessary files.

If you haven't already, You should also run
`rails generate rspec:install` to complete the set up.

Examples:
`rails generate saki:install`
DESC

    def initialize(args=[], options={}, config={})
      super
    end

    def manifest
      empty_directory "spec/#{RequestDir}/support"
      template "request_helper.rb", "spec/#{RequestDir}/request_helper.rb"
      copy_file "helpers.rb", "spec/#{RequestDir}/support/helpers.rb"
    end

    def driver
      @driver = options.webrat? ? 'webrat' : 'capybara'
    end
  end
end

