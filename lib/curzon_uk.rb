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

  extend Cinebase::Vista::TokenHolder

  # @api private
  def self.guest_token_class
    Internal::GuestToken
  end
end
