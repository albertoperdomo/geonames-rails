module GeonamesRails
  module Mappings
    class AlternateName < Base
    protected
      def mappings
        {
          # [0] alternateNameId : the id of this alternate name, int
          :alternate_name_id => 0
          # [1] geonameid : geonameId referring to id in table 'geoname', int
          :geonames_id => 1,
          # [2] isolanguage : iso 639 language code 2- or 3-characters; 4-characters 'post' for postal codes and 'iata','icao' and faac for airport codes, fr_1793 for French Revolution names,  abbr for abbreviation, link for a website, varchar(7)
          :iso_language => 2,
          # [3] alternate name : alternate name or name variant, varchar(200)
          :alternate_name => 3,
          # [4] isPreferredName : '1', if this alternate name is an official/preferred name
          :preferred_name => 4,
          # [5] isShortName : '1', if this is a short name like 'California' for 'State of California'
          :short_name => 5,
        }
      end
    end
  end
end