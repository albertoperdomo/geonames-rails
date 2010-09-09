class Country < ActiveRecord::Base
  has_many :cities
  has_many :geonames_alternate_names, :as => :translatable, :class_name => 'AlternateName'
  
  def localized_name
    translations = geonames_alternate_names.in_language(I18n.locale)
    return name if translations.empty?
    translations.each do |t|
        return t.alternate_name if t.preferred_name?
    end
    translations.first.alternate_name
  end
  
end