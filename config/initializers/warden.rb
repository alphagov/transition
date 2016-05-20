Rails.configuration.middleware.use RailsWarden::Manager do |manager|
  manager.default_strategies :zendesk
  manager.failure_app = UnauthenticatedController
end

# Setup Session Serialization
class Warden::SessionSerializer
  def serialize(record)
    [record.class.name, record.id]
  end

  def deserialize(keys)
    klass, id = keys
    klass.find(:first, :conditions => { :id => id })
  end
end

Warden::Manager.serialize_into_session do |user|
  user.id
end

Warden::Manager.serialize_from_session do |id|
  User.get(id)
end

# Declare your strategies here
Warden::Strategies.add(:zendesk) do
 def authenticate!
   # do stuff

 end
end
