module GeonamesRails
  
  class Loader
    
    def initialize(puller, writer, logger = nil)
      @logger = logger || STDOUT
      @puller = puller
      @writer = writer
    end
    
    def load_data
      @puller.pull if @puller # pull geonames files down
      
      load_countries
      load_divisions
      load_cities
      
      @puller.cleanup if @puller # cleanup the geonames files
    end
    
  protected
    def load_countries
      log_message "opening countries file"
      mappings = []
      File.open(File.join(RAILS_ROOT, 'tmp', 'countryInfo.txt'), 'r') do |f|
        f.each_line do |line|
          # skip comments
          next if line.match(/^#/) || line.match(/^iso/i)
          
          mappings << Mappings::Country.new(line)
          
          log_message "Pre-loaded #{mappings.size} countries"
        end
      end
      country_ids = mappings.collect {|country_mapping| country_mapping[:geonames_id]}
      log_message "opening allCountries file... processign will take some time"
      File.open(File.join(RAILS_ROOT, 'tmp', 'allCountries.txt'), 'r') do |f|
        f.each_line do |line|
          parts = line.split("\t")
          next if parts.size != 19 # bad records
          if (idx = country_ids.index parts[0])
            mappings[idx][:alternate_names] = parts[3]
            log_message "Settings alternate names for #{mappings[idx][:name]} to #{mappings[idx][:alternate_names]}"
          end
        end
      end
      # Now find alternate names...
      mappings.each do |country_mapping|
        result = @writer.write_country(country_mapping)
        log_message result
      end
    end

    def load_divisions
      log_message "opening allCountries file... processign will take some time"
      divisions = []
      File.open(File.join(RAILS_ROOT, 'tmp', 'allCountries.txt'), 'r') do |f|
        f.each_line do |line|
          parts = line.split("\t")
          next if parts.size != 19 # bad records
          next unless parts[6] == 'A' and parts[7] =~ /^ADM[1234]$/ # only admins
          # test: only spain
          # next unless parts[8] == 'ES'
          # end-test
          divisions << Mappings::Division.new(line)
          #break if divisions.size > 500
        end
      end
      result = @writer.write_divisions(divisions)
      log_message result
    end
    
    def load_cities
      %w(cities1000 cities5000 cities15000).each do |city_file|
        load_cities_file(city_file)
      end
    end
    
    def load_cities_file(city_file)
      log_message "Loading city file #{city_file}"
      cities = []
      File.open(File.join(RAILS_ROOT, 'tmp', "#{city_file}.txt"), 'r') do |f|
        f.each_line { |line| cities << Mappings::City.new(line) }
      end
      
      log_message "#{cities.length} cities to process"
      
      cities_by_country_code = cities.group_by { |city_mapping| city_mapping[:country_iso_code_two_letters] }
      
      cities_by_country_code.keys.each do |country_code|
        cities = cities_by_country_code[country_code]
        
        result = @writer.write_cities(country_code, cities)
        
        log_message result
      end
    end
    
    def log_message(message)
      @logger << message
      @logger << "\n"
    end
  end
end