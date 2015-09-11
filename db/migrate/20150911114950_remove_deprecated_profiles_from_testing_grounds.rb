class RemoveDeprecatedProfilesFromTestingGrounds < ActiveRecord::Migration
  REPLACEMENTS = {
    'dhw_use_profile_1_normalised' => 'dhw_profile_1',
    'dhw_use_profile_2_normalised' => 'dhw_profile_2',
    'dhw_use_profile_3_normalised' => 'dhw_profile_3',
    'dhw_use_profile_4_normalised' => 'dhw_profile_4',
    'dhw_use_profile_5_normalised' => 'dhw_profile_5',

    'hp_space_heating_10kw_75m2_100liter'  => 'hp_space_heating_10kw_75m2_100liter_both',
    'hp_space_heating_10kw_100m2_100liter' => 'hp_space_heating_10kw_100m2_100liter_both',
    'hp_space_heating_10kw_150m2_100liter' => 'hp_space_heating_10kw_150m2_100liter_both',

    'anonimous_base_load_1_deprecated'  => 'anonimous_base_load_1',
    'anonimous_base_load_2_deprecated'  => 'anonimous_base_load_2',
    'anonimous_base_load_4_deprecated'  => 'anonimous_base_load_4',
    'anonimous_base_load_5_deprecated'  => 'anonimous_base_load_5',
    'anonimous_base_load_6_deprecated'  => 'anonimous_base_load_6',
    'anonimous_base_load_7_deprecated'  => 'anonimous_base_load_7',
    'anonimous_base_load_8_deprecated'  => 'anonimous_base_load_8',
    'anonimous_base_load_9_deprecated'  => 'anonimous_base_load_9',
    'anonimous_base_load_10_deprecated' => 'anonimous_base_load_10',
    'anonimous_base_load_11_deprecated' => 'anonimous_base_load_1',
    'anonimous_base_load_12_deprecated' => 'anonimous_base_load_2'
  }

  def up
    originals = Hash[LoadProfile.where(key: REPLACEMENTS.keys).map do |profile|
      [profile.id, profile]
    end]

    replacements =
      Hash[LoadProfile.where(key: REPLACEMENTS.values).map do |profile|
        [profile.key, profile]
      end]

      # puts '-----------------'
      # puts originals.inspect
      # puts '================='
      # puts replacements.inspect
      # puts '-----------------'

      # fail 'failed'

    # Start out by removing technology assignments from the originals so that
    # they won't be selected in the testing grounds.
    originals.each do |_, profile|
      profile.technology_profiles.delete_all
    end

    # Replace profiles in testing grounds.
    TestingGround.find_each do |tg|
      changed = false

      tg.technology_profile.each_tech do |tech|
        if originals.keys.include?(tech.profile)
          changed     = true
          new_profile = replacements[REPLACEMENTS[originals[tech.profile].key]]

          if new_profile.nil?
            fail "Missing replacement for #{ originals[tech.profile].key }"
          end

          puts "#{ tg.id } - Replacing #{ originals[tech.profile].key.inspect } with #{ (new_profile && new_profile.key).inspect }"

          tech.profile     = new_profile.id
          tech.profile_key = new_profile.key
        end
      end

      tg.save(validate: false) if changed
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
