namespace :geonames_rails do
  desc 'pull down the geonames data from the server'
  task :download => :environment do
    GeonamesRails::Puller.new.pull
  end
  
  desc 'pull down the geonames data from the server'
  task :cleanup => :environment do
    # TODO: Implement
    puts "TODO: Not implemented yet. Files were not cleaned up."
  end
    
  desc 'load the data from files you already have laying about'
  task :load => :environment do
    if ENV['DISABLE_SOLR']
      puts "Disabling solr indexing"
      class ActsAsSolr::Post
        def self.execute(request)
          true
        end
      end
    end
    RAILS_DEFAULT_LOGGER.silence do
      writer = ENV['DRY_RUN'] ? GeonamesRails::Writers::DryRun.new : GeonamesRails::Writers::ActiveRecord.new
      GeonamesRails::Loader.new(writer).load_data
    end
  end
  
  desc 'Pull down the files, load the database and cleanup the downloaded files'
  task :all => ['geonames_rails:download', 'geonames_rails:load', 'geonames_rails:cleanup']

end