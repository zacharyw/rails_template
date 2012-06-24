#Generate a rails app with user functionality (user model/controller and authentication/authorization)

run "rm public/index.html"
run "rm app/views/layouts/application.html.erb"

rake "db:create"

gem_group :development do
  gem 'ruby-debug-base19x', '<= 0.11.30.pre3'
  gem 'sqlite3'
end

gem_group :test do
  gem 'turn', :require => false
  gem 'rspec-rails'
  gem 'guard-rspec'
  gem 'factory_girl_rails'
  gem 'mocha'
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

generate :model, "User name:string email:string"
generate :controller, "Users"

rake "db:migrate"

inject_into_file 'app\models\user.rb', :after => "class User < ActiveRecord::Base\n" do <<-'RUBY'
  acts_as_authentic

  validates :name, :email, :presence => true
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
    @current_user_session = UserSession.find
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