require "rubygems"
require "sinatra"
require "json"
require "active_record"

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: "#{File.dirname(__FILE__)}/../db/saint_peter_#{Sinatra::Application.environment}.sqlite.db"
)

class RoleBased < ActiveRecord::Base
  self.abstract_class = true
  def self.find_and_update_or_create(attrs)
    obj = find_by_name(attrs[:name])
    if obj
      obj.update_attributes(attrs)
    else
      create(attrs)
    end
  end

  def roles
    str = read_attributes(:roles)
    str.split(/ *, */)
  end
end

class User < RoleBased; end
class Resource < RoleBased; end


set :port, 3333

post '/users/' do
  auth = User.find_and_update_or_create(params)
  auth ? 'Created' : 'Failed'
end

post '/resources' do
  auth = Resource.find_and_update_or_create(params)
  auth ? 'Created' : 'Failed'
end

get '/users/:name/authorizations' do |name|
  user_roles = User.find_by_name(name).roles rescue []
  auth_roles = Resource.find_by_name(params[:resource]).roles rescue []

  authorized = (user_roles - auth_roles).length != user_roles.length

  {
    authorized: authorized
  }.to_json
end
