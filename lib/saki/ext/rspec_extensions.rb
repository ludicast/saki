class RSpec::Core::ExampleGroup
    def self.method_missing(methId, *args)
        parse_opts = lambda {|link , opts, context|
          opts ||= {}
          if opts[:parent]
            parent = context.instance_variable_get('@' + opts[:parent].to_s)
            "/#{parent.class.to_s.tableize}/#{parent.id}" + link
          else
            link
          end
        }

        str = methId.id2name
        if str.match /new_(.*)_path/
             lambda { |context|
               parse_opts.call "/#{$1.pluralize}/new", args.first, context
             }
        elsif str.match /edit_(.*)_path/
            lambda { |context|
                model = context.instance_variable_get "@#{$1}"
                parse_opts.call "/#{model.class.to_s.tableize}/#{model.id}/edit", args.first, context
            }
        elsif str.match /(.*)_path/
          pluralized = $1.pluralize
          if pluralized == $1
            lambda { |context|  parse_opts.call "/#{$1}", args.first, context }
          else
            lambda { |context|
                model = context.instance_variable_get "@#{$1}"
                parse_opts.call "/#{model.class.to_s.tableize}/#{model.id}", args.first, context
            }
          end
        else
          super(methId, [])
        end
   end
end

module RSpec::Core::ObjectExtensions
  def integrate(*args, &block)
    args << {} unless args.last.is_a?(Hash)
    args.last.update :type => :acceptance
    describe(*args, &block)
  end
end
