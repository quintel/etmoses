class EtCurve
  def self.load_file(file)
    Merit::Curve.new(self.values(file))
  end

  private

    def self.values(file)
      CSV.read(file).flatten.map(&:to_f)
    end
end
