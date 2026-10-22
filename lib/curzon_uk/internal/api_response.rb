# frozen_string_literal: true

require "date"

module CurzonUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Fetches cinema and showtime data from the Vista API behind curzon.com
    class ApiResponse
      BASE_URL = "https://digital-api.curzon.com/ocapi/v1/"

      # @return [Array<Hash>] cinemas
      def sites
        client.get("sites").fetch("sites")
      end

      # @param [String] cinema_id site id, e.g. 'ALD1'
      # @param [Date] date business date
      # @return [Hash] showtimes plus their related films and attributes
      def showtimes(cinema_id, date)
        client.get("showtimes/by-business-date/#{date.iso8601}",
                   "siteIds" => cinema_id)
      end

      private

      # Curzon's API needs no Connect-Region-Code.
      def client
        Cinebase::Vista::Client.new(base_url: BASE_URL, region_code: nil,
                                    token: CurzonUk.token)
      end
    end
  end
end
