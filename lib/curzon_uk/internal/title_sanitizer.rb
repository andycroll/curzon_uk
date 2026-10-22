module CurzonUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Sanitize and standardize film titles
    class TitleSanitizer < Cinebase::TitleSanitizer
      # @!method initialize(title)
      #   Constructor
      #   @param [String] title a film title
      #   @return [CurzonUk::Internal::TitleSanitizer]

      # @!method sanitized
      #   sanitized and standardized title
      #   @return [String] sanitised title

      private

      # strings and regex to be removed
      def remove
        [
          /\ADocHouse: /i, # DocHouse strand
          /\AFilm Club: /i # Film Club strand
        ] + COMMON_REMOVE
      end

      # regexes and their replacements
      def replace
        COMMON_REPLACE
      end
    end
  end
end
