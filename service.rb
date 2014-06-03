require "rubygems"
require "sinatra"
require "json"
require "active_record"

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: "#{File.dirname(__FILE__)}/rbac_#{Sinatra::Application.environment}.sqlite.db"
)

class RoleBased < ActiveRecord::Base
  self.abstract_class = true

  def self.find_and_update_or_create(attributes)
    item = find_by_name(attributes[:name])
    if item
      item.update_attributes(attributes)
    else
      create(attributes)
    end
  end

  def roles
    str = read_attribute(:roles)
    str.split(/ *, */)
  end
end

class User < RoleBased; end
class Resource < RoleBased; end

set :port, 3333

post '/users' do
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
  puts "#{name} authorized to access #{params[:resource]} #{authorized}"

  {
    authorized: authorized
  }.to_json
end
