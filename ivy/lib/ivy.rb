module Ivy
  # Public: Path to the directory in which static data files files typically
  # reside. This will normally have subfolders like curves/, technologies/, etc.
  #
  # Returns a Pathname.
  def self.data_dir
    @data_dir ||= Rails.root.join('data')
  end

  # Public: Sets the path to the direction in which the data files reside.
  #
  # Returns the path provided.
  def self.data_dir=(path)
    path = path.is_a?(Pathname) ? path : Pathname.new(path.to_s)
    path = Rails.root.join(path) if path.relative?

    Rails.cache.clear

    @data_dir = path
  end

  # Public: Wrap around a block of code to work with a temporarily altered
  # +data_dir+ setting.
  #
  # directory - The new, but temporary, data_dir path.
  #
  # Returns the result of your block.
  def self.with_data_dir(directory)
    previous      = data_dir
    self.data_dir = directory

    yield
  ensure
    self.data_dir = previous
  end
end
