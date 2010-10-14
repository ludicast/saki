require 'rspec/core'

module Saki
  module RestfulPathwayHelpers
    def shows_in_list(resource, attrs = nil)
      visit "/#{resource.to_s.pluralize}"
      resource_instance = eval "@#{resource}"
      if attrs
        attrs.each do |attr|
          page.should have_content(resource_instance.send(attr))
        end
      elsif respond_to?("displays_#{resource}")
        send "displays_#{resource}"
      else
        page.should have_content(resource_instance.name)
      end
      has_index_link_list(resource_instance)
    end

    def has_index_link_list(item, opts = {})
      has_link_for item, opts
      has_link_for_editing item, opts
      has_link_for_deleting item, opts
      has_link_for_creating item.class.to_s.tableize.singularize, opts
    end

    def has_show_link_list(item, opts = {})
      has_link_for_editing item, opts
      has_link_for_deleting item, opts
      has_link_for_indexing item.class.to_s.tableize.singularize, opts
    end

    def shows_failure_on_invalid_update_of(model)
      if respond_to?("invalidate_#{model}_form")
        send("invalidate_#{model}_form")
      else
        fill_in "#{model}[name]", :with => ""
      end
      click_button "Update"
      page.should have_xpath("//input[@type='submit' and starts-with(@value, 'Update')]")
      page.should have_content("error")
    end

    def shows_failure_on_invalid_create
      click_button "Create"
      page.should have_xpath("//input[@type='submit' and starts-with(@value, 'Create')]")
      page.should have_content("error")
    end

    def lets_me_edit_the(item_name)
      eval %{
    @#{item_name} = factory_build item_name
    fill_in_#{item_name}_details
    click_button "Update"
    refetch(item_name)
    has_#{item_name}_details
    }
    end

    def create(item_name)
      eval %{
    puts "building"
    @#{item_name} = factory_build :#{item_name}
    puts "responding" + @home.inspect
    if respond_to? :before_#{item_name}_create
      before_#{item_name}_create
    end
    puts "ran before"
    fill_in_#{item_name}_details
    puts "filled in details"
    click_button "Create"
    puts "created"
    }
    end


    def lets_me_create_the(item_name)
      eval %{
      create(:#{item_name})
      refetch(item_name)
      if respond_to? :after_#{item_name}_create
        after_#{item_name}_create
      end
      has_#{item_name}_details
      has_show_link_list(@#{item_name})
    }
    end


  end

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
      page.should have_xpath("//a[@href='#{href}']")
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

class RSpec::Core::ExampleGroup

      def self.method_missing(methId, *args)
        parse_opts = lambda {|link , opts, context|
          opts ||= {}
          if opts[:parent]
            "/#{opts[:parent].to_s.pluralize}/#{(context.instance_variable_get('@' + opts[:parent].to_s)).id}" + link
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

RSpec.configuration.include Saki::GeneralHelpers
RSpec.configuration.include Saki::AcceptanceHelpers, :type => :acceptance
RSpec.configuration.include Saki::RestfulPathwayHelpers, :type => :acceptance