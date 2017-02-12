# Devise for authentication, and Pundit for authorization. It reshapes the Devise
# views and forms with Bootstrap markup.
#
# Does not migrate the database. Check the generated User model and migration
# to see if there's anything you want to change.

# Can be used with 'rails new', but generally intended to be applied to an existing rails app to add authentication/authorization:

# $ bin/rails app:template LOCATION=~/users_template.rb

gem 'devise'
gem 'pundit'

run 'bundle install'

  run 'rails generate devise:install'
  run 'rails generate devise:views'

  environment "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }", env: 'development'

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
    <%= f.check_box :remember_me %>
  <% end -%>

  <%= f.submit \"Log in\" %>
<% end %>

<%= render \"devise/shared/links\" %>
  """
  end

  inject_into_file 'app/controllers/application_controller.rb', :after => "class ApplicationController < ActionController::Base\n" do
    "include Pundit\n"
  end

  git add: '--all .'
  #git commit: "-a -m 'Add devise and pundit'"
