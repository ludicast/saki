module Saki
  module GeneralHelpers
    extend ActiveSupport::Concern
    def default_factory(name, opts = {})
      Factory name, opts
    end

    module ClassMethods
      def with_existing resource, opts={}, &block
        context "with exisiting #{resource}" do
          before do
            instance_variable_set "@#{resource}", default_factory(resource, opts)
          end
          module_eval &block
        end
      end

      def with_signed_in resource, opts={}, &block
        context "with signed in #{resource}" do
          before do
            instance_variable_set "@#{resource}", default_factory(resource, opts)
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