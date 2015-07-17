module Paperclip
  # Given an uploaded curve, alters the values so that the area underneath the
  # curve satisfies the given constraint. The two supported constraints are :max
  # and :sum.
  #
  # Given :sum, the total of all values in the curve will sum to 1.0. This
  # allows the user to provide the total annual demand for the technology. For
  # example:
  #
  #   Given:   [2.0, 4.0, 2.0, 1.0, 1.0]
  #   Becomes: [0.2, 0.4, 0.2, 0.1, 0.1]
  #
  # Given :max, the highest value in the curve will be given a value of 1.0, and
  # all other values scaled relative to this. For example:
  #
  #   Given:   [2.0, 4.0, 2.0, 1.0, 1.0]
  #   Becomes: [0.5, 1.0, 0.5, 0.25, 0.25]
  #
  class ScaledCurve < Processor
    def self.scale(curve, scale_by)
      divisor =
        case scale_by
          when :sum then curve.reduce(:+)
          when :max then curve.max
          else           1.0
        end

      curve.map { |value| value / divisor }
    end

    def make
      format   = File.extname(file.path)
      basename = File.basename(file.path, format)

      curve    = Merit::Curve.load_file(file.path)
      scaled   = self.class.scale(curve, @options[:scale_by])

      Tempfile.new([basename, format ? ".#{format}" : '']).tap do |dest|
        dest.puts(scaled.map(&:to_s).join("\n"))
        dest.rewind
      end
    end
  end # ScaledCurve
end # Paperclip
