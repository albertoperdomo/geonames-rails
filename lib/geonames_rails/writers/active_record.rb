module GeonamesRails
  module Writers
    class ActiveRecord
      
      def write_country(country_mapping)  
        iso_code = country_mapping[:iso_code_two_letter]
        c = Country.find_or_initialize_by_iso_code_two_letter(iso_code)
      
        created_or_updating = c.new_record? ? 'Creating' : 'Updating'
        
        c.attributes = country_mapping.slice(:iso_code_two_letter,
          :iso_code_three_letter,
          :iso_number,
          :name,
          :capital,
          :continent,
          :geonames_id)
        c.save!
        
        "#{created_or_updating} db record for #{iso_code}"
      end

      def write_divisions(division_mappings)
        countries_by_code = Country.all.group_by {|c| c.iso_code_two_letter}
        divisions_by_parent_code = Hash.new {|h,k| h[k] = [] }
        division_mappings.each do |division_mapping|
          country = countries_by_code[division_mapping[:country_iso_code_two_letters]]
          next if country.nil?
          division = Division.find_or_initialize_by_geonames_id(division_mapping[:geonames_id])
          division.country = country.first
          division.attributes = division_mapping.slice(:name,
            :alternate_names,
            :latitude,
            :longitude,
            :country_iso_code_two_letters,
            :geonames_timezone_id)
          parent_trace = [
            division_mapping[:country_iso_code_two_letters],
            division_mapping[:admin_1_code],
            division_mapping[:admin_2_code],
            division_mapping[:admin_3_code],
            division_mapping[:admin_4_code]
          ].collect {|x| x == "" ? nil : x}.compact
          division.code = parent_trace.join("|")
          parent_codes = parent_trace[0..-2]
          division.level = parent_codes.size
          division.save!
          if division.level > 1
            divisions_by_parent_code[parent_codes] << division.id
          end
        end
        divisions_by_parent_code.each_pair do |p_code, div_ids|
          # Some divisions have unknown parents... try to find one
          parent = nil
          while parent.nil? && p_code.size > 1
            parent = Division.find_by_code p_code.join('|')
            p_code = p_code[0..-2] if parent.nil? # prepare for next iteration
          end
          next if p_code.size < 2 # only country
          puts "updating #{div_ids.size} children of #{parent.nil? ? 'nil' : parent.name} (#{p_code})"
          Division.update_all "parent_id = #{parent.id}", "id in (#{div_ids.join(',')})"
        end

        "Processed #{division_mappings.size} divisions"
      end

      
      def write_cities(country_code, city_mappings)    
        country = Country.find_by_iso_code_two_letter(country_code)
        return "Skipped unknown country code #{country_code} with #{city_mappings.length} cities" if country.nil?
        city_mappings.each do |city_mapping|
          city = City.find_or_initialize_by_geonames_id(city_mapping[:geonames_id])
          city.country = country
        
          city.attributes = city_mapping.slice(:name,
            :latitude,
            :longitude,
            :country_iso_code_two_letters,
            :population,
            :geonames_timezone_id)
        
          city.save!
        end
        
        "Processed #{country.name}(#{country_code}) with #{city_mappings.length} cities"
      end

    end
  end
end