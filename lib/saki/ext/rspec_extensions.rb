module Saki
  module RspecExampleGroupOverrides  
    extend ActiveSupport::Concern
    
    module InstanceMethods
      def method_missing(methId, *args)
        case methId.to_s
          when /(.*)=/ then instance_variable_set "@#{$1}", args[0]
          else (instance_variable_defined?("@#{methId}") ? instance_variable_get("@#{methId}") : super(methId, *args))   
        end
      end
    end
    
    module ClassMethods
      def method_missing(methId, *args)
        str = methId.id2name
        if str.match /new_(.*)_path/
             lambda { |context|
               parse_link_opts "/#{$1.pluralize}/new", args.first, context
             }
        elsif str.match /edit_(.*)_path/
            lambda { |context|
                model = context.send "#{$1}"
                parse_link_opts "/#{model.class.to_s.tableize}/#{model.to_param}/edit", args.first, context
            }
        elsif str.match /(.*)_path/
          pluralized = $1.pluralize
          if pluralized == $1
            lambda { |context|  parse_link_opts "/#{$1}", args.first, context }
          else
            lambda { |context|
                model = context.send "#{$1}"
                parse_link_opts "/#{model.class.to_s.tableize}/#{model.to_param}", args.first, context
            }
          end
        else
          super
        end
      end

private
      def parse_link_opts(link, opts, context)
        opts ||= {}
        if opts[:parent]
          parent = context.instance_variable_get('@' + opts[:parent].to_s)
          "/#{parent.class.to_s.tableize}/#{parent.to_param}" + link
        else
          link
        end
      end
    end
  end
end

RSpec::Core::ExampleGroup.send :include, Saki::RspecExampleGroupOverrides

module RSpec::Core::ObjectExtensions
  def integrate(*args, &block)
    args << {} unless args.last.is_a?(Hash)
    args.last.update :type => :request
    describe(*args, &block)
  end
end
