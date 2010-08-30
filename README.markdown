# Saki - For times when you can't swallow Cucumber

Saki lets you do acceptance testing on top of RSpec.  It is considerably more terse than cucumber, but does not sacrifice readability.

Are you tired of having DRY code, but tests that seem to babble on "for the length of a bible"?  Me too.  How about RSpec code that is hard to follow, when Ruby itself is as "human" as a programming language can get?  I hate it too.

Enter Saki stage left.

## How terse is it?

Well, here's a sample that sets up contexts that create a user and then visit an edit path for that user.

	with_existing :user do
		on_visiting edit_path_for(:user) do
			it { should yadda.yadda }
		end
	end

This code basically injects some "before blocks", so it would look like this in vanilla RSpec:

	context "when a user exists" do
		before { @user = Factory :user }
		context "when I visit the page for editing that user" do
			before { visit edit_user_path(:user) }
    		it {should yadda.yadda}
  		end
	end

I feel Saki is much more expressive.

## What class-level methods does it use (for setting up contexts)?

`with_existing` takes a factory name as a symbol and assigns it to on instance variable with the same name.

`on_visiting` takes a path either as a string or as a lambda that executes within a before block to set up the path.  This is useful when the code is dependent on an instance variable for path creation.

`on_visiting` has several helper functions for establishing a path: `create_path_for`, `index_path_for`, `edit_path_for`, `show_path_for` and `new_path_for`.  These paths all take resource names for establishing a path.  In cases where the resource is nested, it has a :parent => parent_resource option.  This lets you set up blocks like:

    on_visiting index_path_for(:auction)

`where` is a function taking as a parameter either a lambda to execute in the before block, or a symbol which is the name of a function to execute in the before block.

Finally, to simplify setting up integration tests, anything you wrap in an `integrate` block (like `describe`) sets the test type to acceptance.

## Installation

Saki installs with two steps.  First, add to your Gemfile:

    gem 'saki'

Then to fill out the directories run:

    rails generate saki:install

Then, as long as your acceptance specs require the acceptance_helper file you should be good to go.
    
## What assumptions does it make?  

It assumes that you are using factory_girl and capybara or webrat, though it probably would work fine with other test factories.  If you need another factory in the mix, just redefine the `default_factory` method to behave how you want.

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
