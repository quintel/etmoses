module CurveComponent
  VALID_CSV_TYPES = %w(
    data:text/csv
    text/csv
    text/plain
    application/octet-stream
    application/vnd.ms-excel
  ).freeze

  # Creates a dynamic module which may be mixed in to classes which need to have
  # an uploaded curve.
  #
  # paperclip_options - An optional hash of options to provide when setting up
  #                     Paperclip with `has_attached_file`.
  #
  # For example:

  #   include CurveComponent.module(styles: {
  #     demand_scaled:   { scale_by: :sum, processors: [:scaled_curve] },
  #     capacity_scaled: { scale_by: :max, processors: [:scaled_curve] }
  #   })
  #
  # Returns a module.
  def self.module(paperclip_options = {})
    Module.new do
      extend ActiveSupport::Concern

      included do
        has_attached_file :curve, paperclip_options

        before_post_process :skip_processing_with_invalid_bytes

        validate :validate_curve_length
        validates_attachment :curve, presence: true,
          content_type: { content_type: CurveComponent::VALID_CSV_TYPES },
          size: { less_than: 100.megabytes }
      end

      def self.inspect
        'CurveComponent.module'
      end

      def as_json(*)
        super.merge('values' => network_curve.to_a)
      end

      # Public: Returns the Network::Curve which containing each of the load profile
      # values.
      def network_curve(scaling = :original)
        Rails.cache.fetch(cache_key(scaling)) do
          Network::Curve.load_file(curve.path(scaling))
        end
      end

      # TODO: Refactor to use paperclip_options.
      def scaled_network_curve(scaling, range)
        Network::Curve.new(
          case scaling
          when :capacity_scaled
            Paperclip::ScaledCurve.scale(network_curve(range), :max)
          when :demand_scaled
            Paperclip::ScaledCurve.scale(network_curve(range), :sum)
          else
            network_curve(range)
          end.to_a
        )
      end

      private

      # Internal: Files containing invalid bytes should not be handled by the
      # ScaledCurve processor. Validation will catch these errors and show a
      # message to the visitor.
      def skip_processing_with_invalid_bytes
        pending_curve
      rescue ArgumentError => ex
        ex.message.include?('invalid byte sequence') ? false : raise(ex)
      end

      # Internal: Asserts that the uploaded file has enough data to be used in
      # a calculation.
      def validate_curve_length
        return unless curve = pending_curve

        # 8760 is permitted in tests, but not *currently* officially supported
        # in the front-end.
        unless curve.length == 8760 || curve.length == 35040
          errors.add(:curve, "must have 35,040 values, but the uploaded " \
                             "file has #{ curve.length }")
        end
      rescue ArgumentError => ex
        if ex.message.include?('invalid byte sequence')
          errors.add(:curve, 'contains invalid data; the curve should ' \
                             'contain only numbers, one on each line')
        else
          raise ex
        end
      end

      # Internal: Reads the pending upload into a Network::Curve.
      def pending_curve
        return false unless curve && curve.queued_for_write[:original]
        Network::Curve.load_file(curve.queued_for_write[:original].path)
      end

      def cache_key(scaling)
        "profile.#{ id }.#{ curve_updated_at.to_s(:db) }.#{ scaling }"
      end
    end
  end # module
end # CurveComponent
