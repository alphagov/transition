module PaperTrail
  class Version < ActiveRecord::Base
    attr_accessible :user_id
  end
end
