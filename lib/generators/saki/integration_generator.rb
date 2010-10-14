require 'generators/rspec/integration/integration_generator'
puts "loading rspec generator"

module Rspec
  module Generators
    class IntegrationGenerator < Base
      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"

      source_paths << File.join(File.dirname(__FILE__), 'templates')

      def create_integration_file
        template 'full_integration_spec.rb',
                 File.join('spec/acceptance', class_path, "#{table_name}_spec.rb")
      end
      def resource_name
        file_name.tableize.singularize
      end
    end
  end
end
