Given(/^i visit the landing page\.$/) do
  visit root_path
end

When(/^fill out the registration form\.$/) do
  within "#new_user" do
    fill_in 'user_email',    :with => 'foobar@example.com'
    fill_in 'user_name',     :with => 'Foo Bar'
    fill_in 'user_password', :with => 'simple-password'
  end
end

When(/^click on the singup button\.$/) do
  within "#new_user" do
    click_on 'Sign Up'
  end
end

Then(/^i should be on the after signup page$/) do
  page.should have_content("Need Help?")
  page.should have_content("Welcome Foo Bar")
  current_path.should eq("/after_signup")
  
end

Then(/^a new User with given values is registred\.$/) do
  @user = User.find_by_email("foobar@example.com")
  @user.should_not be_nil
end

Then(/^it is not confirmed\.$/) do
  @user.confirmed_at.should be_nil
  @user.confirmation_token.should_not be_nil
end

Given(/^I am an registered and confirmed user\.$/) do
  @password = SecureRandom.hex(10)

  @user = FactoryGirl.create :user, :password => @password
  @user.confirmed_at = Time.now
  @user.save!
end

When(/^i fill out the login form\.$/) do
  within '#sign_in' do
    fill_in 'user_email',    :with => @user.email
    fill_in 'user_password', :with => @password
  end
end

When(/^click on the signin button\.$/) do
  within '#sign_in' do
    click_on 'Sign In'
  end
end

Then(/^i should be logged in\.$/) do
  page.should have_content(@user.name)
  page.should have_content("Signed in successfully")
end