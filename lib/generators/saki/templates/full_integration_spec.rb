require File.dirname(__FILE__) + '/acceptance_helper'
<%-
  extend SchemaUtil
  for_base do
    resource_class = resource_name.classify.constantize
    @pairs = resource_class.columns_hash.map do |key, value|
      [key.to_s, value.type.to_s]
    end
  end

%>
integrate "<%= resource_name %> resource" do

  def fill_in_<%= resource_name %>_details<%-
      @pairs.each do |pair|
        unless ["id", "created_at", "updated_at"].include? pair[0] 
    %>
    fill_in "<%= resource_name %>[<%= pair[0] %>]", :with => @<%= resource_name %>.<%= pair[0] %><%-
        end
      end
    %>
  end 

  def has_<%= resource_name %>_details<%-
      @pairs.each do |pair|
        unless ["id", "created_at", "updated_at"].include? pair[0]
    %>
    page.should have_content(@<%= resource_name %>.<%= pair[0] %>)<%-
        end
      end
    %>
  end

  on_visiting new_<%= resource_name %>_path do
    it { lets_me_create_the(:<%= resource_name %>) }
    it { shows_failure_on_invalid_create }
  end

  with_existing :<%= resource_name %> do
    it { shows_in_list(:<%= resource_name %>) }

    on_visiting edit_<%= resource_name %>_path do
      it { lets_me_edit_the(:<%= resource_name %>) }
      it { shows_failure_on_invalid_update_of(:<%= resource_name %>) }
    end
  end

end