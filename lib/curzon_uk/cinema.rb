module CurzonUk
  # The object representing a cinema on the Curzon website
  class Cinema < Cinebase::Cinema
    # @!attribute [r] id
    #   @return [String] the Vista site id of the cinema, e.g. 'ALD1'

    # UK postcode
    POSTCODE = /[A-Z]{1,2}\d[A-Z\d]? ?\d[A-Z]{2}/i.freeze

    # Constructor
    # @param [String] id the cinema id, e.g. 'ALD1' or 'ald1'
    # @return [CurzonUk::Cinema]
    def initialize(id)
      @id = id.to_s.upcase
    end

    # Return basic cinema information for all cinemas
    # @return [Array<CurzonUk::Cinema>]
    # @example
    #   CurzonUk::Cinema.all
    #   #=> [<CurzonUk::Cinema>, <CurzonUk::Cinema>, ...]
    def self.all
      sites_hash.keys.map { |id| new(id) }
    end

    # @!method address
    #   Address of the cinema
    #   @return [Hash] of different address parts
    #   @see #adr

    # Address of the cinema
    # @return [Hash] contains :street_address, :extended_address,
    # :locality, :region, :postal_code, :country_name
    # @example
    #   cinema = CurzonUk::Cinema.new('SOH1')
    #   cinema.adr
    #   #=> {
    #         street_address:   '99 Shaftesbury Avenue',
    #         extended_address: nil,
    #         locality:         'London',
    #         region:           nil,
    #         postal_code:      'W1D 5DY',
    #         country_name:     'United Kingdom'
    #       }
    # @note Uses method naming as at http://microformats.org/wiki/adr
    def adr
      lines = address_lines
      if (match = lines.last&.match(/\A(.*?),?\s*(#{POSTCODE.source})\z/i))
        lines.pop
        lines << match[1] unless match[1].empty?
        postal_code = match[2]
      end
      street_address = lines.shift
      locality = lines.pop
      {
        street_address:   street_address,
        extended_address: lines.empty? ? nil : lines.join(', '),
        locality:         locality,
        region:           nil,
        postal_code:      postal_code,
        country_name:     'United Kingdom'.freeze
      }
    end

    # Brand of the cinema
    # @return [String] which will always be 'Curzon'
    def brand
      'Curzon'.freeze
    end

    # The name of the cinema
    # @return [String]
    # @example
    #   CurzonUk::Cinema.new('SOH1').name
    #   #=> 'Soho'
    def name
      site_hash.dig('name', 'text').to_s
    end

    # The url of the cinema on the Curzon website
    # @return [String]
    def url
      "https://www.curzon.com/venues/#{name.downcase.gsub(/[^a-z0-9]+/, '-').gsub(/\A-|-\z/, '')}/"
    end

    # @api private
    def self.sites_hash
      @sites_hash ||= CurzonUk::Internal::ApiResponse.new.sites.to_h do |site|
        [site.fetch('id'), site]
      end
    end
    private_class_method :sites_hash

    private

    # Curzon ends each line with a comma
    def address_lines
      address = site_hash.dig('contactDetails', 'addressV2') || {}
      %w(line1 line2 line3 line4).filter_map do |key|
        text = address.dig(key, 'text').to_s.strip.delete_suffix(',').strip
        text unless text.empty?
      end
    end

    def site_hash
      @site_hash ||= self.class.send(:sites_hash).fetch(id, {})
    end
  end
end
