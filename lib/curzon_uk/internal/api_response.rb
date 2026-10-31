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
        get("sites").fetch("sites")
      end

      # @param [String] cinema_id site id, e.g. 'ALD1'
      # @param [Date] date business date
      # @return [Hash] showtimes plus their related films and attributes
      def showtimes(cinema_id, date)
        get("showtimes/by-business-date/#{date.iso8601}",
                   "siteIds" => cinema_id)
      end

      private

      def get(path, query = {})
        token = CurzonUk.token
        client(token).get(path, query)
      rescue Cinebase::Vista::AuthenticationError
        CurzonUk.reject_token!(token)
        raise
      end

      # Curzon's API needs no Connect-Region-Code.
      def client(token)
        Cinebase::Vista::Client.new(base_url: BASE_URL, region_code: nil,
                                    token: token)
      end
    end
  end
end
