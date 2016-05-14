gem 'bootstrap-sass', '~> 3.3.6'
gem 'bootstrap3_form_builder', '1.0.1'

gem 'devise'
gem 'pundit'

gem_group :development, :test do
  gem 'rspec-rails', '~> 3.5.0.beta3'
  gem 'factory_girl_rails'
end

after_bundle do
  git :init

  append_file '.gitignore' do
    "*.iml\n"
    ".idea/*\n"
  end

  git add: '.'
  git commit: "-a -m 'Initial Rails skeleton'"

  remove_file 'app/assets/javascripts/application.js'

  create_file 'app/assets/javascripts/application.js.coffee' do
  """
  ###
  This is a manifest file that'll be compiled into application.js, which will include all the files
  listed below.

  Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
  or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.

  It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
  compiled file. JavaScript code in this file should be added after the last require_* statement.

  Read Sprockets README (https:github.com/rails/sprockets#sprockets-directives) for details
  about supported directives.
  ###

  #= require jquery
  #= require jquery_ujs
  #= require turbolinks
  #= require_tree .
  """
  end

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

  generate('bootstrap3_form_builder:install')

  inject_into_file 'app/views/layouts/application.html.erb', :after => '<head>\n' do
    '<meta name="viewport" content="width=device-width, initial-scale=1">'
  end

  git add: '.'
  git commit: "-a -m 'Add Twitter Bootstrap'"

  run 'rails generate rspec:install'

  comment_lines 'spec/rails_helper.rb', /fixture_path/

  inject_into_file 'spec/rails_helper.rb', :after => '# config.fixture_path = "#{::Rails.root}/spec/fixtures"\n' do
    'config.include FactoryGirl::Syntax::Methods'
  end

  git add: '.'
  git commit: "-a -m 'Setup rspec and factory girl'"

  run 'rails generate devise:install'
  run 'rails generate devise:views'
  generate(:controller, 'Home', 'index')

  environment "add config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }", env: 'development'

  inject_into_file 'app/views/layouts/application.html.erb', :after => '<body>\n' do
    """
    <div class=\"container\">
      <div class=\"row\">
        <% if notice %>
          <p class=\"alert alert-info\"><%= notice %></p>
        <% end %>
        <% if alert %>
            <p class=\"alert alert-danger\"><%= alert %></p>
        <% end %>
    """
  end

  inject_into_file 'app/views/layouts/application.html.erb', :after => '<%= yield %>\n' do
    """
      </div>
    </div>
    """
  end

  route 'root to: "home#index"'

  remove_file 'app/views/devise/confirmations/new.html.erb'
  remove_file 'app/views/devise/passwords/edit.html.erb'
  remove_file 'app/views/devise/passwords/new.html.erb'
  remove_file 'app/views/devise/registrations/edit.html.erb'
  remove_file 'app/views/devise/registrations/new.html.erb'
  remove_file 'app/views/devise/sessions/new.html.erb'

  create_file 'app/views/devise/confirmations/new.html.erb' do
    """
<h2>Resend confirmation instructions</h2>

<%= bootstrap_form_for(resource, as: resource_name, url: confirmation_path(resource_name), html: { method: :post }) do |f| %>
  <%= devise_error_messages! %>

    <%= f.email_field :email, autofocus: true, value: (resource.pending_reconfirmation? ? resource.unconfirmed_email : resource.email) %>

    <%= f.submit \"Resend confirmation instructions\" %>
<% end %>

<%= render \"devise/shared/links\" %>
    """
  end

  create_file 'app/views/devise/passwords/edit.html.erb' do
    """
<h2>Change your password</h2>

<%= bootstrap_form_for(resource, as: resource_name, url: password_path(resource_name), html: { method: :put }) do |f| %>
  <%= devise_error_messages! %>
  <%= f.hidden_field :reset_password_token %>

  <%= f.password_field :password, label: 'New Password', autocomplete: \"off\", help_block: @minimum_password_length ? \"(#{@minimum_password_length} characters minimum)\" : '' %>
  <%= f.password_field :password_confirmation, autocomplete: \"off\" %>

  <%= f.submit 'Change my password' %>
<% end %>

<%= render \"devise/shared/links\" %>
  """
  end

  create_file 'app/views/devise/passwords/new.html.erb' do
    """
<h2>Forgot your password?</h2>

<%= bootstrap_form_for(resource, as: resource_name, url: password_path(resource_name), html: { method: :post }) do |f| %>
  <%= devise_error_messages! %>

  <%= f.email_field :email, autofocus: true %>

  <%= f.submit 'Send me reset password instructions' %>
<% end %>

<%= render \"devise/shared/links\" %>
  """
  end

  create_file 'app/views/devise/registrations/edit.html.erb' do
    """
<h2>Edit <%= resource_name.to_s.humanize %></h2>

<%= bootstrap_form_for(resource, as: resource_name, url: registration_path(resource_name), html: { method: :put }) do |f| %>
  <%= devise_error_messages! %>

    <%= f.email_field :email, autofocus: true %>

  <% if devise_mapping.confirmable? && resource.pending_reconfirmation? %>
    <div>Currently waiting confirmation for: <%= resource.unconfirmed_email %></div>
  <% end %>

  <%= f.password_field :password, autocomplete: \"off\", help_block: \"(leave blank if you don't want to change it)\" %>

  <%= f.password_field :password_confirmation, autocomplete: \"off\" %>

  <%= f.password_field :current_password, autocomplete: \"off\", help_block: '(we need your current password to confirm your changes)' %>

  <%= f.submit \"Update\" %>
<% end %>

<h3>Cancel my account</h3>

<p>Unhappy? <%= button_to \"Cancel my account\", registration_path(resource_name), data: { confirm: \"Are you sure?\" }, method: :delete, class: 'btn btn-danger' %></p>

<%= link_to \"Back\", :back %>
"""
  end

  create_file 'app/views/devise/registrations/new.html.erb' do
    """
<h2>Sign up</h2>

<%= bootstrap_form_for(resource, as: resource_name, url: registration_path(resource_name)) do |f| %>
  <%= devise_error_messages! %>
  <%= f.email_field :email, autofocus: true %>
  <%= f.password_field :password, autocomplete: \"off\", help_block: @minimum_password_length ? \"(#{@minimum_password_length} characters minimum)\" : '' %>
  <%= f.password_field :password_confirmation, autocomplete: \"off\" %>

  <%= f.submit \"Sign up\" %>
<% end %>

<%= render \"devise/shared/links\" %>
    """
  end

  create_file 'app/views/devise/sessions/new.html.erb' do
    """
<h2>Log in</h2>

<%= bootstrap_form_for(resource, as: resource_name, url: session_path(resource_name)) do |f| %>
    <%= f.email_field :email, autofocus: true %>

    <%= f.password_field :password, autocomplete: \"off\" %>

  <% if devise_mapping.rememberable? -%>
    <div class=\"form-group\">
      <%= f.check_box :remember_me %>
      <%= f.label :remember_me, class: 'form-control' %>
    </div>
  <% end -%>

  <%= f.submit \"Log in\" %>
<% end %>

<%= render \"devise/shared/links\" %>
  """
  end

  inject_into_file 'app/controllers/application_controller.rb', :after => "class ApplicationController < ActionController::Base\n" do
    "include Pundit"
  end

  git add: '.'
  git commit: "-a -m 'Add devise and pundit'"
end

run 'bundle install'
