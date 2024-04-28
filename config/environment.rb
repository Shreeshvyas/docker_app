# Load the Rails application.
require_relative "application"

Rails.application.configure do
  config.hosts << "docker-app-a82l.onrender.com"
end

# Initialize the Rails application.
Rails.application.initialize!
