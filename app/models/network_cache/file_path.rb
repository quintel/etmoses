module NetworkCache
  module FilePath
    def file_name(key)
      "#{ file_path }/#{ Digest::SHA256.hexdigest(key) }.tmp"
    end

    def file_path
      "#{Rails.root}/tmp/networks/#{Rails.env}/#{@testing_ground.id}/#{strategy_prefix}"
    end

    def strategy_prefix
      @opts.except(:capping_fraction).values.any? ? 'features' : 'basic'
    end
  end
end
