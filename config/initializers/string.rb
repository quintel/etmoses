class String
  #
  # Removes all possible characters that can be interpreted as classes or id's
  # in a jQuery selector.
  #
  def jquery_safe
    self.gsub(/\.|\#/, '')
  end
end
