#Generate a rails app with user functionality (user model/controller and authentication/authorization)

remove_file "public/index.html"
remove_file "app/views/layouts/application.html.erb"
remove_file "app/assets/images/rails.png"

remove_file "README.rdoc"
create_file "README.md"

rake "db:create"

gem_group :test, :development do
  gem 'turn', :require => false
  gem 'rspec-rails'
  gem 'guard-rspec'
  gem 'factory_girl_rails'
  gem 'mocha'
  gem 'ruby-debug-base19x', '<= 0.11.30.pre3'
  gem 'sqlite3'
end

gem 'haml'
gem 'haml-rails'
gem 'jquery-rails'
gem 'bootstrap2_form_builder'

gem 'authlogic'
gem 'cancan'

gem 'capistrano'
gem 'capistrano-ext'

run "bundle install"

run "rails g bootstrap2_form_builder:install -t haml"
run "rails g authlogic:session"
run "rails generate rspec:install"
run "rails g cancan:ability"

generate :model, "User name:string email:string crypted_password:string password_salt:string persistence_token:string perishable_token:string login_count:integer failed_login_count:integer last_request_at:datetime current_login_at:datetime last_login_at:datetime current_login_ip:string last_login_ip:string"
generate :controller, "Users"
generate :controller, "Sessions"

rake "db:migrate"

inject_into_file 'app\models\user.rb', :after => "class User < ActiveRecord::Base\n" do <<-'RUBY'
  acts_as_authentic do |c|
    c.require_password_confirmation = false
  end

  validates :name, :email, :crypted_password, :password_salt, :persistence_token, :perishable_token, :login_count, :failed_login_count, :presence => true
RUBY
end

inject_into_file 'app\controllers\users_controller.rb', :after => "class UsersController < ApplicationController\n" do <<-'RUBY'
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:edit, :update, :show]

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])

    if @user.save
      flash[:notice] = "Account created"
      redirect_to root_url
    else
      render :action => :new
    end
  end

  def edit
    @user = @current_user
  end

  def update
    @user = @current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated"
      redirect_to account_url
    else
      render :action => :edit
    end
  end

  def show
    @user = User.find(params[:id])
  end
RUBY
end

inject_into_file 'app\controllers\sessions_controller.rb', :after => "class SessionsController < ApplicationController\n" do <<-'RUBY'
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy

  def new
    @session = Session.new
  end

  def create
    @session = Session.new(params[:session])
    if @session.save
      flash[:notice] = "Login successful"
      redirect_back_or_default new_pick_path
    else
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = "Logout successful"
    redirect_back_or_default new_session_url
  end
RUBY
end

append_file '.gitignore' do
  "*.iml\n"
  ".idea/*\n"
end

inject_into_file 'app\helpers\application_helper.rb', :after => "module ApplicationHelper\n" do <<-'RUBY'
  def text_icon(text, icon, white=false)
    css_class = "icon-" + icon
    if white
      css_class = css_class + " icon-white"
    end

    (text + " " + content_tag("i", "", :class => css_class)).html_safe
  end

  def icon_text(text, icon, white=false)
    css_class = "icon-" + icon
    if white
      css_class = css_class + " icon-white"
    end

    (content_tag("i", "", :class => css_class) + " " + text).html_safe
  end
RUBY
end

inject_into_file 'app\controllers\application_controller.rb', :after => "protect_from_forgery\n" do <<-'RUBY'
  helper_method :current_user_session,:current_user

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  protected
  def discard_flash_if_xhr
    flash.discard if request.xhr?
  end

  private
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = Session.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end

  def require_user
    unless current_user
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to new_user_session_url
      false
    end
  end

  def require_no_user
    if current_user
      store_location
      flash[:notice] = "You must be logged out to access this page"
      redirect_to account_url
      false
    end
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
RUBY
end

create_file "app/views/layouts/application.html.haml" do <<-'HAML'
!!! HTML
%html
  %head
    %title
      = (yield :title)

    = stylesheet_link_tag "application", :media => "all"
    = javascript_include_tag "application"
    = yield :javascripts
    = csrf_meta_tags

    /HTML5 shim, for IE6-8 support
    /[if lt IE 9]
      %script{:src => "http://html5shim.googlecode.com/svn/trunk/html5.js", :type => "text/javascript"}
  %body
    = yield
HAML
end

create_file "app/views/users/_form.html.haml" do <<-'HAML'
=bootstrap_form_for @user do |form|
  =form.text_field :name
  =form.text_field :email
  =form.password_field :password
  =form.submit "Submit"
HAML
end

create_file "app/views/users/new.html.haml" do <<-'HAML'
= content_for :title do
  Register

= render :partial => 'form'
HAML
end

create_file "app/views/users/edit.html.haml" do <<-'HAML'
= content_for :title do
  Edit Profile

= render :partial => 'form'
HAML
end

create_file "app/views/sessions/new.html.haml" do <<-'HAML'
=content_for :title do
  Log In
= render("bootstrap2_form_builder/error_messages", :target => @session)
= form_for @session do |form|
  = form.label :email
  = form.text_field :email
  = form.label :password
  = form.password_field :password
  %div.form-actions
    = form.submit "Login", :class => "btn btn-primary"
    = link_to text_icon("Don't have an account? Create one!", "share-alt"), register_path
HAML
end

route "match 'register' => 'users#new', :as => :register"
route "match 'account' => 'users#edit', :as => :account"
route "resources :session, :only => [:new, :create, :destroy]"
route "match 'login' => 'sessions#new', :as => :login"
route "match 'logout' => 'sessions#destroy', :as => :logout"
route "resources :users, :except => [:index, :destroy]"

initializer 'ruby_utility_methods.rb', <<-CODE
class Object
  def not_nil?
    !nil?
  end

  def not_blank?
    !blank?
  end
end
CODE

capify!

git :init
git :add => "."
git :commit => "-m 'Generated initial application'"