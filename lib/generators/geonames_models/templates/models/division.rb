class Division < ActiveRecord::Base
  belongs_to :country
  belongs_to :parent, :class_name => "Division"
              
end