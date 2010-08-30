module Saki
  module AcceptanceHelpers
    extend ActiveSupport::Concern

    def default_factory(name)
      Factory name
    end

    def add_opts(link, opts)
      if opts[:parent]
        "/#{opts[:parent].class.to_s.tableize}/#{opts[:parent].id}" + link
      else
        link
      end
    end

    def has_link_for(model, opts = {})
      href = add_opts "/#{model.class.to_s.tableize}/#{model.id}", opts
      page.should have_xpath("//a[@href='#{href}' and not(@rel)]")
    end

    def has_link_for_editing(model, opts = {})
      href = add_opts "/#{model.class.to_s.tableize}/#{model.id}/edit", opts
      page.should have_xpath("//a[@href='#{href}']")
    end

    def has_link_for_deleting(model, opts = {})
      href = add_opts "/#{model.class.to_s.tableize}/#{model.id}", opts
      page.should have_xpath("//a[@href='#{href}' and @data-method='delete']")
    end

    def has_link_for_creating(model_type, opts = {})
      href = add_opts "/#{model_type.to_s.tableize}/new", opts
      page.should have_xpath("//a[@href='#{href}']")
    end

    def has_link_for_indexing(model_type, opts = {})
      href = add_opts "/#{model_type.to_s.tableize}", opts
      page.should have_xpath("//a[@href='#{href}']")
    end  

    module ClassMethods
      def with_existing resource, &block
        context "with exisiting #{resource}" do
          before { eval "@#{resource} = default_factory :#{resource}" }
          module_eval &block
        end
      end

      def on_following_link_to path, &block
        context "on following link" do
          before do
            if path.is_a? String
              path = path
            else
              path =  path.call(self)
            end
            has_link(path)
            visit path
          end
          module_eval &block
        end
      end

      def on_visiting path, &block
        context "on visiting" do
          before do
            if path.is_a? String
              visit path
            else
              visit path.call(self)
            end
          end
          module_eval &block
        end
      end

      def add_opts(link, opts, context)
        if opts[:parent]
          "/#{opts[:parent].to_s.pluralize}/#{(context.instance_variable_get('@' + opts[:parent].to_s)).id}" + link
        else
          link
        end
      end

      def edit_path_for(resource, opts = {})
        lambda do |context|
          add_opts "/#{resource.to_s.pluralize}/#{(context.instance_variable_get('@' + resource.to_s)).id}/edit", opts, context
        end
      end

      def show_path_for(resource, opts = {})
        lambda do |context|
          add_opts "/#{resource.to_s.pluralize}/#{(context.instance_variable_get('@' + resource.to_s)).id}", opts, context
        end
      end

      def create_path_for(resource, opts = {})
        lambda do |context|
          add_opts "/#{resource.to_s.pluralize}/new", opts, context
        end
      end

      def index_path_for(resource, opts = {})
        lambda do |context|
          add_opts "/#{resource.to_s.pluralize}", opts, context
        end
      end

      def where(closure, &block)
        context "anonymous closure" do
          before { instance_eval &closure }
          module_eval &block
        end
      end
    end
  end
end

RSpec.configuration.include Saki::AcceptanceHelpers, :type => :acceptance