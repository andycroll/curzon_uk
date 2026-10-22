# frozen_string_literal: true

require "json"

module CurzonUk
  module Internal
    # Reads the public guest token from the Curzon website's page data
    class GuestToken < Cinebase::Vista::GuestToken
      PAGE_URL = "https://www.curzon.com/"

      private

      # Missing pages carry the same page data.
      def accepted_statuses
        %w[200 404]
      end

      def bundled_curl
        File.expand_path("../../../vendor/curl-impersonate/bin/curl-impersonate", __dir__)
      end

      def extract_token(html)
        JSON.parse(html[/window\.initialData\s*=\s*(.+?);\s*$/, 1].to_s).dig("api", "authToken")
      end
    end
  end
end
