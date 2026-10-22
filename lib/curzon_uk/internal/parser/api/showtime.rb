# frozen_string_literal: true

require "time"

module CurzonUk
  # @api private
  module Internal
    module Parser
      module Api
        # Parses a single Vista showtime into performance attributes
        class Showtime
          BOOKING_URL = "https://www.curzon.com/ticketing/seats/?showtimeId="

          # Vista attribute names
          VARIANTS = {
            "Baby Club" => "baby",
            "Open Captioned" => "subtitled",
            "Screening followed by a Q&A" => "q&a"
          }.freeze

          # @param [Hash] data one showtime
          # @param [Hash{String => Hash}] films related films keyed by id
          # @param [Hash{String => Hash}] attributes related attributes keyed by id
          def initialize(data, films:, attributes:)
            @data = data
            @films = films
            @attributes = attributes
          end

          # @return [Hash] options for CurzonUk::Performance.new
          def to_hash
            {
              booking_url: BOOKING_URL + @data.fetch("id"),
              dimension: @data["requires3dGlasses"] ? "3d" : "2d",
              festival: Cinebase::Festival.from_title(title, year: starting_at.year),
              film_name: TitleSanitizer.new(title).sanitized,
              film_year: Cinebase::TitleSanitizer.film_year(title),
              starting_at: starting_at,
              variant: variant
            }
          end

          private

          def starting_at
            Time.iso8601(@data.dig("schedule", "startsAt")).utc
          end

          def title
            @films.fetch(@data.fetch("filmId")).dig("title", "text")
          end

          def variant
            @data.fetch("attributeIds", []).filter_map do |id|
              VARIANTS[@attributes.dig(id, "name", "text").to_s.strip]
            end.uniq
          end
        end
      end
    end
  end
end
