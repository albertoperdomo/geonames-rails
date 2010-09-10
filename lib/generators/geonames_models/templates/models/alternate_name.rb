class AlternateName < ActiveRecord::Base
  belongs_to :translatable, :polymorphic => true
  
  named_scope :in_language, lambda { |lang| { :conditions => ["iso_language = ?", "es"] } }
end