# Saki - For times when you can't swallow Cucumber

Saki lets you do acceptance testing on top of RSpec with considerably more terseness than cucumber, but without sacrificing readability.  Are you tired of having DRY code, but tests that seem to babble on "for the length of a bible"?  Me too.  How about RSpec code that is hard to follow, while Ruby itself is as "human" as a programming language can get?  I hate it too.

Enter Saki stage left.

## How terse is it?

Well, here's a sample that assumes a user exists and visits an edit path for that user.  Me like.

	with_existing :user do
		on_visiting edit_path_for(:user) do
			it { should yadda.yadda }
		end
	end

This code basically injects some before blocks behind the scene, so it would look like this in vanilla RSpec:

	context "when a user exists" do
		before { @user = Factory :user }
		context "when I visit the page for editing that user" do
			before { visit edit_user_path(:user) }
    		it {should yadda.yadda}
  		end
	end

Much more expressive don't you think?  And smooth to follow, no?

## What assumptions does it make?  

It assumes that you are using factory_girl and capybara, though it probably would work fine with other test factories and webrat.  If you need another factory in the mix, just redefine the default_factory method to behave how you want.

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
