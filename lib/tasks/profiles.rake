namespace :profiles do
  desc <<-DESC
    Imports profiles stored in tmp/new-profiles

    Reads the tmp/new-profiles directory, if present, and imports any profiles
    which do not already exist in the database. If a profile with the same name
    exists, the new profile file will be used to replace the old one.
  DESC
  task import: :environment do
    dir = Rails.root.join('tmp/new-profiles')

    if dir.directory?
      Pathname.glob(dir.join('*.csv')).each do |path|
        begin
          key        = path.basename(path.extname).to_s
          profile    = LoadProfile.by_key(key).first || LoadProfile.new(key: key)
          curve_file = File.open(path)

          profile.attributes = { curve: curve_file }
          profile.curve_content_type = 'text/csv'

          if profile.new_record?
            # Assume that imported profiles should not be editable by users.
            profile.locked = true
          end

          profile.save(validate: false)

          puts "Imported #{ key }"
        rescue Exception => ex
          puts "Failed to import #{ key } - #{ ex.message }"
        ensure
          curve_file && curve_file.close
        end
      end
    else
      puts 'tmp/new-profiles directory does not exist; nothing to import'
    end
  end # :import
end # :profiles
