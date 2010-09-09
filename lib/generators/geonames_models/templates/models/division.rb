class Division < ActiveRecord::Base
  belongs_to :country
  belongs_to :parent, :class_name => "Division"
  has_many :geonames_alternate_names, :as => :translatable, :class_name => 'AlternateName'

  # Returns an array with all the parents of this administrative region
  #
  # The first position in the array is the +country+ and up to 3 more positions
  # can contain the ADM1, ADM2 and ADM3 divisions containing this one
  def containers
    return @containers unless @containers.nil?
    container_codes = []
    codes = code.split('|')
    container_codes << (codes = codes[0..-2]).join('|') while codes.size > 1
    # first is country code
    @containers = [country]
    # second, third can be parent administrative division if not nil
    # NOTE container codes is like: ["ES|58|PO", "ES|58", "ES"] (country is last)
    @containers += Division.find_all_by_code container_codes[0..-2], :order => :level if container_codes.size > 1
    return @containers
  end
  
  def localized_name
    translations = geonames_alternate_names.in_language(I18n.locale)
    return name if translations.empty?
    translations.each do |t|
        return t.alternate_name if t.preferred_name?
    end
    translations.first.alternate_name
  end
  
end