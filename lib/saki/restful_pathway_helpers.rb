module Saki
  module RestfulPathwayHelpers
    def shows_in_list(resource, attrs = nil, parent = nil)
      if parent
        visit "/#{parent.class.to_s.tableize}/#{parent.id}/#{resource.to_s.pluralize}"
      else
        visit "/#{resource.to_s.pluralize}"
      end
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
      has_index_link_list(resource_instance, {:parent => parent})
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
        @#{item_name} = factory_build :#{item_name}
        if respond_to? :before_#{item_name}_create
          before_#{item_name}_create
        end
        fill_in_#{item_name}_details
        click_button "Create"
      }
    end


    def lets_me_create_without_links_the(item_name)
      eval %{
        create(:#{item_name})
        refetch(item_name)
        if respond_to? :after_#{item_name}_create
          after_#{item_name}_create
        end
        has_#{item_name}_details
      }
    end
    

    def lets_me_create_the(item_name, opts = {})
      lets_me_create_without_links_the(item_name)
      has_show_link_list(eval("@#{item_name}"), opts)
    end

    def refetch(item_name)
      eval "@#{item_name} = respond_to?(:refetch_#{item_name}_func) ? refetch_#{item_name}_func : @#{item_name}.class.where(:name => @#{item_name}.name).first"
    end

    def factory_build(name, hash = {})
      Factory.build name, hash
    end

    def factory(name, hash = {})
      Factory name, hash
    end

  end
end

