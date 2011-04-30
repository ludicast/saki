module Saki
  module GeneralHelpers
    extend ActiveSupport::Concern
    def default_factory(name, opts = {})
      Factory name, opts
    end

    def default_factory_build(name, opts = {})
      Factory.build name, opts
    end

    module ClassMethods
      def with_existing resource, opts={}, &block
        context "with exisiting #{resource}" do
          define_method resource do
            eval "@#{resource}"
          end
          before do
            eval %{
              @___current_resource = @#{resource} = default_factory(resource, opts)
            }
          end
          module_eval &block
        end
      end

      def that_has_an resource, opts={}, &block
        context "that has a/an #{resource}" do
          before do
            eval %{
              @#{resource} = default_factory(resource, opts)
              @___current_resource.#{resource.to_s.pluralize} << @#{resource}
              @#{resource}.save!
              @___current_resource.save!
              @___current_resource = @#{resource}
            }
          end
          module_eval &block
        end
      end

      alias_method :that_has_a, :that_has_an

      def with_signed_in resource, opts={}, &block
        context "with signed in #{resource}" do
          before do
            eval "@___current_resource = @#{resource} = default_factory(resource, opts)"
            eval "sign_in @#{resource}"
          end
          module_eval &block
        end
      end

      def where(executable, *opts, &block)
        context "anonymous closure" do
          before { instance_eval &executable }
          module_eval &block
        end
      end
    end
  end
end