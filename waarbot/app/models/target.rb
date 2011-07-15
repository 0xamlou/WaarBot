class Target < ActiveRecord::Base


validates_uniqueness_of :ingame_id
end
