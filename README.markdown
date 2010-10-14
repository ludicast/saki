# Saki - For times when you can't swallow Cucumber

Are you tired of having DRY code, but tests that seem to babble on "for the length of a bible"?  Me too.  How about test code that is hard to follow, when Ruby itself is clear as day?  I hate it too.

Enter Saki stage left.

Saki lets you do acceptance testing on top of RSpec.  It is considerably more terse than Cucumber, but does not sacrifice readability.  Saki also does not use Given/When/Then syntax because the thought is that there is little return other than familiarity for Cucumber users.

## How terse is it?

Well, here's a sample that sets up contexts that create a user and then visit an edit path for that user.

	with_existing :user do
		on_visiting edit_user_path do
			it { should let_me_edit(@user) }
		end
	end

This code basically injects some "before blocks", so it would look like this in vanilla RSpec:

	context "a user exists" do
		before { @user = Factory :user }
		context "I visit the page for editing that user" do
			before { visit "/users/#{@user.id}/user" }
			it { should let_me_edit(@user) }
  		end
	end

I believe the Saki example has the following benefits over vanilla RSpec:

* It saves two lines of code.
* It standardizes the code.  Whereas a context string might accidentally get out of sync with the code (unmaintained comments, anyone?), with Saki this would probably cause a test to fail.
* It is much more expressive.  You read the test and you immediately know what it does.
* Any exceptions to the rule (complicated setups, etc.) would now stick out like sore thumbs, as they should.

The only assumption is that you are using factories instead of fixtures.  You also get more out of it in a conventional RESTful application, where the paths don't have too many gotchas.

## Methods provided for setting up contexts

`with_existing` takes a factory name as a symbol and assigns its created object to an instance variable with the same name.  It also takes options so you can have blocks start with:

    with_existing :user, :state => "happy" do...

`with_signed_in` is similar to `with_existing` but after creating the object it passes it into a `sign_in` method:

    with_signed_in :admin do...

`on_visiting` preferably uses some dynamic functions for establishing a path: `new_X_path`, `Xs_path`, `edit_X_path`, `X_path` and `new_X_path`.  In these cases, substitute X for the resource name (e.g. `new_user_path`).  

Note that for examples like `edit_user_path`, it behaves with a slight difference from the rails route helpers, because it assumes that there already exists an instance variable named `@user`.  Since the `edit_user_path` call occurs when there is no `@user`, we can't mention it explicitly.

For cases where the resource is nested, these path helpers have a :parent => parent_resource option.  This lets you set up blocks like:

    on_visiting auctions_path(:parent => :user) do ...

`on_visiting` also takes a path as a string, or a proc that executes within a before block to set up the path.  It also takes a symbol which is the name of a method name.  This is useful when the code is dependent on an instance variable for path creation.

    path_for_user = proc { user_path(@user) }

    on_visiting path_for_user do ...

or you can do

    def my_user_path
        user_path(@user)
    end

    on_visiting :my_user_path do ...

`on_following_link_to` works the same as on_visiting, but it first validates that the link exists, and then follows it.

`where` is a function taking as a parameter a proc to execute in the before block.

    def self.creating_a_user
        proc {
            @user = Factory.build @user
            fill_in "user[email]", :with => @user.email
            click_button "Create"
        }
    end

    on_following_link_to new_user_path do
        where creating_a_user do
            specify { page.should have_content(@user.email) }
        end
    end

Obviously the return for this is where you have functions acting as "reusable steps" in the style of Cucumber.  In addition your "before blocks" are more expressive.

Finally, to simplify setting up integration tests, anything you wrap in an `integrate` block (like `describe`) sets the test type to acceptance. This is the default `describe` function of the generators, but feel free to use the regular describe block as long as you set its :type option to :acceptance.

## Installation

Saki installs with two steps.  First, add to your Gemfile:

    gem 'saki'

Then to fill out the directories run:

    rails generate saki:install

You can generate new acceptance tests with `rails generate saki:spec SPEC_NAME`.  This automatically generates tests like

    require File.dirname(__FILE__) + '/acceptance_helper'

    integrate "author resource" do

        on_visiting new_author_path do
            specify { fail "not implemented" }
        end

        with_existing :author do
            on_visiting edit_author_path do
                specify { fail "not implemented" }
            end
            on_visiting author_path do
                specify { fail "not implemented" }
            end
            on_visiting authors_path do
                specify { fail "not implemented" }
            end
        end
    end

## Saki as your default integration testing library

If you want to use Saki for generating integration tests for your scaffolding, simply add to your development.rb file

    require "generators/saki/integration_generator"

Then, provided that your integration library is set to :rspec, Saki will create integration tests for your scaffolding for complete test coverage.  Note that these cases are left simple for now, but can be built up upon feedback.  Also you might need to implement additional functions depending on your use case.

## Why no specs/tests for Saki, oh test guy?

They'll get there :).  Saki is extracted from some spec helpers I used in moving from Cucumber to Steak.  Once I realized they also work as helpers for vanilla RSpec acceptance testing I made them a separate gem.

## Why are there ugly command-line descriptions?

I haven't pimped that up yet, but will at some point.  Personally I'm a "green-dot" guy and just care what line a test fails on.

## References

The motivation behind my migration from Cucumber and to Saki, are described in blog posts [Encumbered by Cucumber](http://ludicast.com/articles/1), [Introducing Saki](http://ludicast.com/articles/2).

## Ruby 1.9.2

To work with Ruby 1.9.2 the `where` function takes procs but not lambdas.

## Thanks

The generators are stolen directly from Steak with some adjustments.

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

MIT License
