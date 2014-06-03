module Rack
  class RBAC
    def initialize(app, rbac_host, &block)
      @app = app
      @rbac_host = rbac_host
      @rbac_port = 3333
      @extract_user_and_resource = block
    end

    def call(env)
      user, resource = @extract_user_and_resource.call(env).values_at(:user, :resource)
      authorized = authorized?(user, resource)
      if authorized
        @app.call(env)
      else
        [401, { 'Content-Type' => 'text/html' }, ["Unauthorized\n"]]
      end
    rescue => error
      [500, { 'Content-Type' => 'text/html' }, ["Unable to authorize : #{error.message}\n"]]
    end

    private

    def authorized?(user, resource)
      response = Net::HTTP.get(@rbac_host, "/users/#{user}/authorizations?resource=#{resource}", @rbac_port)
      JSON.parse(response)["authorized"]
    rescue
      false
    end
  end
end

use Rack::RBAC, "localhost" do |env|
  puts env.inspect
  {
    user: CGI.escape(env["HTTP_X_USER"]),
    resource: CGI.escape(env['PATH_INFO'])
  }
end

run Proc.new { |env| [200, { "Content-Type" => "text/html" }, "Rack::RBAC gave you access\n"] }
