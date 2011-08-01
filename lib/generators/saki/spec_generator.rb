require 'rails/generators'

module Saki
  class SpecGenerator < Rails::Generators::NamedBase

    def resource_name
      file_name.tableize.singularize
    end

    source_root File.join(File.dirname(__FILE__), 'templates')

    desc <<-DESC
Description:
Create an request spec for the feature NAME in the
'spec/request' folder.

Example:
`rails generate saki:spec author`

Creates an request spec for the "author" feature:
spec/request/author_spec.rb
DESC

    def manifest
      empty_directory File.join('spec/request', class_path)
      file_name.gsub!(/_spec$/,"")
      template 'request_spec.rb', File.join('spec/request', class_path, "#{file_name}_spec.rb")
    end
  end
end

