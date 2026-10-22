# CurzonUk

A simple gem to pull cinemas and performances from the Vista API behind the [Curzon website](https://www.curzon.com) and spit out useful formatted info.

## Installation

Add this line to your application's Gemfile:

    gem 'curzon_uk'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install curzon_uk

## Usage

The gem conforms to the API set down in the `cinebase` gem, [andycroll/cinebase](https://github.com/andycroll/cinebase), which provides a lot of useful base vocabulary and repetitive code for this series of cinema focussed gems.

Performance titles are sanitized as much as possible, removing years, Curzon's DocHouse and Film Club strand prefixes, festival prefixes and other markers.

### Guest token

Every API call needs the public guest token the Curzon website gives each
visitor. Fetch one before anything else:

``` ruby
CurzonUk.acquire_token!
CurzonUk::Cinema.all
```

This shells out to **`curl-impersonate`**, not ordinary system `curl`, using its
Chrome 150 TLS/HTTP profile, and reads `window.initialData.api.authToken` from
`https://www.curzon.com/`. No browser or JavaScript execution is needed.

Platform-specific gem packages include the pinned `curl-impersonate` 2.2.3
executable for glibc Linux (x86-64, ARM64) and macOS (Intel, Apple Silicon).
On other platforms, or when installing from Git, install a
[curl-impersonate release](https://github.com/lexiforest/curl-impersonate/releases/tag/v2.2.3)
yourself and put it on your `PATH` or pass its path:

``` ruby
CurzonUk.acquire_token!(curl: '/opt/curl-impersonate/curl-impersonate')
```

Or supply your own current guest JWT, without the `Bearer ` prefix:

``` ruby
CurzonUk.token = ENV.fetch('CURZON_TOKEN')
```

Tokens currently last 12 hours. The gem checks the declared expiry but does not
verify the signature. Missing, expired or rejected tokens raise
`CurzonUk::AuthenticationError`; call `CurzonUk.acquire_token!` again. Normal
API calls never acquire or renew a token automatically.

### Cinema

Cinema ids are Vista site ids, such as `'SOH1'` for Soho.

``` ruby
CurzonUk::Cinema.all
#=> [<CurzonUk::Cinema ...>, <CurzonUk::Cinema ...>, ...]

cinema = CurzonUk::Cinema.new('SOH1')
#=> <CurzonUk::Cinema ...>

cinema.adr
#=> {
  street_address:   '99 Shaftesbury Avenue',
  extended_address: nil,
  locality:         'London',
  region:           nil,
  postal_code:      'W1D 5DY',
  country_name:     'United Kingdom'
}

cinema.brand
#=> 'Curzon'

cinema.full_name
#=> 'Curzon Soho'

cinema.url
#=> 'https://www.curzon.com/venues/soho/'
```

### Performances

`Performance.at` returns performances for an inclusive range of business dates,
defaulting to today in London and the following 13 days. It makes one request
per day.

``` ruby
CurzonUk::Performance.at('SOH1', from: Date.today, to: Date.today + 2)
#=> [<CurzonUk::Performance ...>, <CurzonUk::Performance ...>, ...]

performance = CurzonUk::Performance.at('SOH1').first
#=> <CurzonUk::Performance ...>

performance.film_name
#=> 'Fatherland'

performance.film_year
#=> nil # from the title, e.g. 2026 for 'Street Fighter (2026)'

performance.dimension
#=> '2d'

performance.variant
#=> ['q&a']

performance.subtitled?
#=> false # true for open captioned screenings

performance.festival
#=> nil # e.g. #<data Cinebase::Festival name="UKJFF", year=2026>

performance.starting_at
#=> 2026-10-23 10:00:00 UTC

performance.booking_url
#=> 'https://www.curzon.com/ticketing/seats/?showtimeId=SOH1-57865'

performance.cinema_name
#=> 'Soho'

performance.cinema_id
#=> 'SOH1'
```

Variants are `baby`, `q&a` and `subtitled`. Curzon doesn't tag audio
languages, so `language` is always `nil`.

## Tests

```sh
bundle exec rake          # unit tests against fixtures
bundle exec rake live     # live API, needs curl-impersonate or CURZON_TOKEN
```

Fixtures in `test/fixtures/api` are hand-written: invented films and addresses
in the shape of Vista responses, never recorded API output.
`test/support/api_shapes.rb` describes the fields the gem reads. The unit suite
checks the fixtures against it and the live suite checks real responses, held
only in memory. When the API changes, update the shape first, then the fixtures.

## Releasing

Bump the version, merge, then run the **Release Gem** workflow in GitHub
Actions. It builds the source and four platform gems, publishes them through
RubyGems trusted publishing (no MFA code needed) and tags the release. Versions
already on RubyGems are skipped, so a failed run can be rerun.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
