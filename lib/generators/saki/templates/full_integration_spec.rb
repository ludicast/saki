require File.dirname(__FILE__) + '/acceptance_helper'

integrate "<%= resource_name %> resource" do

  def fill_in_<%= resource_name %>_details<%-
      attributes.each do |attribute|
    %>
    fill_in "<%= resource_name %>[<%= attribute.name %>]", :with => @<%= resource_name %>.<%= attribute.name %><%-
      end
    %>
  end 

  def has_<%= resource_name %>_details<%-
      attributes.each do |attribute|
    %>
    page.should have_content(@<%= resource_name %>.<%= attribute.name %>)<%-
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