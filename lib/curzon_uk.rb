require 'json'

require 'cinebase'
require 'cinebase/vista'

require_relative './curzon_uk/version'

require_relative './curzon_uk/internal/api_response'
require_relative './curzon_uk/internal/guest_token'
require_relative './curzon_uk/internal/title_sanitizer'

require_relative './curzon_uk/internal/parser/api/showtime'

require_relative './curzon_uk/cinema'
require_relative './curzon_uk/performance'

# curzon_uk gem
module CurzonUk
  AuthenticationError = Cinebase::Vista::AuthenticationError

  # A raw guest JWT, without the "Bearer " prefix. Never persisted by the gem.
  class << self
    attr_accessor :token

    # Explicit acquisition/renewal; ordinary API calls never launch a subprocess.
    def acquire_token!(curl: nil)
      self.token = Internal::GuestToken.new(curl: curl).fetch
    end
  end
end
