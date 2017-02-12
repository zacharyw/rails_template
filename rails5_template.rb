# To be used with the Rails 5 'new' generator. Builds out a website structure
# with the Twitter Bootstrap CSS framework (scss), Rspec/FactoryGirl for testing,
# and gems for RubyMine debugging.

# example:
# rails new blog -m ~/template.rb

gem 'bootstrap-sass', '~> 3.3.6'
gem 'bootstrap3_form_builder', '1.0.1'
gem 'therubyracer', platforms: :ruby
gem 'draper', '~> 3.0.0.pre1'

gem_group :development, :test do
  gem 'rspec-rails', '~> 3.5.0.beta3'
  gem 'factory_girl_rails'
  gem 'debase'
  gem 'ruby-debug-ide'
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'timecop'
  gem 'awesome_print'
end

gem_group :test do
  gem 'capybara'
end

after_bundle do
  git :init

  #Ignore Intellij files
  append_file '.gitignore' do
    "*.iml\n"
    ".idea/*\n"
  end

  git add: '--all .'
  git commit: "-a -m 'Initial Rails skeleton'"

  # Use sass for the base css file.
  remove_file 'app/assets/stylesheets/application.css'
  create_file 'app/assets/stylesheets/application.scss' do
  """
/*
 * This is a manifest file that'll be compiled into application.css, which will include all the files
 * listed below.
 *
 * Any CSS and SCSS file within this directory, lib/assets/stylesheets, vendor/assets/stylesheets,
 * or any plugin's vendor/assets/stylesheets directory can be referenced here using a relative path.
 *
 * You're free to add application-wide styles to this file and they'll appear at the bottom of the
 * compiled file so the styles you add here take precedence over styles defined in any other CSS/SCSS
 * files in this directory. Styles in this file should be added after the last require_* statement.
 * It is generally better to create a new file per style scope.
 *
 */

@import \"bootstrap-sprockets\";
@import \"bootstrap\";
  """
  end
  
  inject_into_file 'app/assets/javascripts/application.js', :after => "//= require jquery\n" do
    "//= require bootstrap-sprockets"
  end

  inject_into_file 'config/application.rb', :after => "class Application < Rails::Application\n" do
"""
    config.web_console.whitelisted_ips = '10.0.2.2'
    config.web_console.development_only = false
"""
  end

  generate('bootstrap3_form_builder:install')

  inject_into_file 'app/views/layouts/application.html.erb', :after => "<head>\n" do
    " <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n"
  end

  git add: '--all .'
  git commit: "-a -m 'Add Twitter Bootstrap'"

  run 'rails generate rspec:install'

  comment_lines 'spec/rails_helper.rb', /fixture_path/

  inject_into_file 'spec/rails_helper.rb', :after => "# config.fixture_path = \"\#{::Rails.root}/spec/fixtures\"\n" do
    "config.include FactoryGirl::Syntax::Methods"
  end

  git add: '--all .'
  git commit: "-a -m 'Setup rspec and factory girl'"

  generate(:controller, 'Home', 'index')

  inject_into_file 'app/views/layouts/application.html.erb', :after => "<body>\n" do
    """
    <div class=\"container\">
      <div class=\"row\">
        <% if notice %>
          <p class=\"alert alert-info\"><%= notice %></p>
        <% end %>
        <% if alert %>
            <p class=\"alert alert-danger\"><%= alert %></p>
        <% end %>
      </div>
    """
  end

  inject_into_file 'app/views/layouts/application.html.erb', :after => "<%= yield %>\n" do
    """
    </div>
    """
  end

  route 'root to: "home#index"'

  git add: '--all .'
  git commit: "-a -m 'Add home controller.'"
end

run 'bundle install'

