require File.dirname(__FILE__) + '/request_helper'

integrate "<%= resource_name %> resource" do

  on_visiting new_<%= resource_name %>_path do
    specify { fail "not implemented" }
  end

  with_existing :<%= resource_name %> do
    on_visiting edit_<%= resource_name %>_path do
       specify { fail "not implemented" }
    end
    on_visiting <%= resource_name %>_path do
       specify { fail "not implemented" }
    end
    on_visiting <%= resource_name.pluralize %>_path do
       specify { fail "not implemented" }
    end
  end

end