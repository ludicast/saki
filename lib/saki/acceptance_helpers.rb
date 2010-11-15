
module Saki
  module AcceptanceHelpers
    extend ActiveSupport::Concern


    def get_path(path)
      if path.is_a? String
        path
      elsif path.is_a? Symbol
        send path
      else
        path.call(self)
      end
    end

    def add_opts(link, opts = {})
      if opts[:parent]
        link = "/#{opts[:parent].class.to_s.tableize}/#{opts[:parent].id}" + link
      end
      if opts[:format]
        link = link + ".#{opts[:format]}"
      end
      link
    end

    def has_link(href)
      begin
        page.should have_xpath("//a[@href='#{href}']")
      rescue Exception => e
        onclick = "javascript: window.location='#{href}';"
        page.should have_xpath(%{//button[@onclick="#{onclick}"]})
      end

    end

    def has_link_for(model, opts = {})
      href = add_opts "/#{model.class.to_s.tableize}/#{model.id}", opts
      page.should have_xpath("//a[@href='#{href}' and not(@rel)]")
    end

    def has_link_for_editing(model, opts = {})
      href = add_opts "/#{model.class.to_s.tableize}/#{model.id}/edit", opts
      has_link href
    end

    def has_link_for_deleting(model, opts = {})
      href = add_opts "/#{model.class.to_s.tableize}/#{model.id}", opts
      page.should have_xpath("//a[@href='#{href}' and @data-method='delete']")
    end

    def has_link_for_creating(model_type, opts = {})
      href = add_opts "/#{model_type.to_s.tableize}/new", opts
      has_link href
    end

    def has_link_for_indexing(model_type, opts = {})
      href = add_opts "/#{model_type.to_s.tableize}", opts
      has_link href
    end

    def should_be_on(page_name)
      current_path = URI.parse(current_url).path
      if page_name.is_a? String
        current_path.should == page_name
      else
        current_path.should match(page_name)
      end
    end

    module ClassMethods
      def on_following_link_to path, &block
        context "on following link" do
          before do
            path = get_path(path)
            has_link(path)
            visit path
          end
          module_eval &block
        end
      end

      def on_visiting path, &block
        context "on visiting" do
          before do
            visit get_path(path)
          end
          module_eval &block
        end
      end

      def visiting_path path, &block
        context "on visiting" do
          before do
            visit (instance_eval &path)
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
    end
  end
end
