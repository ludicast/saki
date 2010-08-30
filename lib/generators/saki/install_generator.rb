require 'rails/generators'
AcceptanceDir = "acceptance"

module Saki
  class InstallGenerator < Rails::Generators::Base
    class_option :webrat, :desc => 'Use Webrat.', :type => :boolean
    class_option :capybara, :desc => 'Use Capybara.', :type => :boolean

    source_root File.join(File.dirname(__FILE__), 'templates')

    desc <<-DESC
Description:
Sets up Saki in your Rails project. This will generate the
spec/acceptance directory and the necessary files.

If you haven't already, You should also run
`rails generate rspec:install` to complete the set up.

Examples:
`rails generate saki:install`
DESC

    def initialize(args=[], options={}, config={})
      puts "Defaulting to Capybara..." if options.empty?
      super
    end

    def manifest
      empty_directory "spec/#{AcceptanceDir}/support"
      template "acceptance_helper.rb", "spec/#{AcceptanceDir}/acceptance_helper.rb"
      copy_file "helpers.rb", "spec/#{AcceptanceDir}/support/helpers.rb"
    end

    def driver
      @driver = options.webrat? ? 'webrat' : 'capybara'
    end
  end
end

