require_relative '../../../test_helper'

class CurzonUk::Internal::ApiResponseTest < Minitest::Test
  include ApiFixturesHelper

  BASE_URL = 'https://digital-api.curzon.com/ocapi/v1'.freeze

  def setup
    CurzonUk.token = 'guest-jwt'
  end

  def teardown
    CurzonUk.token = nil
    super
  end

  def test_sites_sends_token_without_region
    stub_request(:get, "#{BASE_URL}/sites")
      .with { |request| request.headers['Authorization'] == 'Bearer guest-jwt' && !request.headers.key?('Connect-Region-Code') }
      .to_return(status: 200, body: sites_json)

    assert_equal %w(CAN2 SOH1 VIC1), api.sites.map { |site| site['id'] }
  end

  def test_showtimes
    stub_request(:get, "#{BASE_URL}/showtimes/by-business-date/2026-10-24")
      .with(query: { 'siteIds' => 'SOH1' })
      .to_return(status: 200, body: showtimes_json('SOH1'))

    showtimes = api.showtimes('SOH1', Date.new(2026, 10, 24))

    assert_equal %w(businessDate relatedData showtimes), showtimes.keys.sort
  end

  def test_missing_token_raises_before_request
    CurzonUk.token = nil

    assert_raises(CurzonUk::AuthenticationError) { api.sites }
  end

  def test_rejected_token_raises
    stub_request(:get, "#{BASE_URL}/sites").to_return(status: 401)

    assert_raises(CurzonUk::AuthenticationError) { api.sites }
  end

  def test_rejected_token_is_cleared
    stub_request(:get, "#{BASE_URL}/sites").to_return(status: 401)

    assert_raises(CurzonUk::AuthenticationError) { api.sites }

    assert_nil CurzonUk.token
  end

  private

  def api
    CurzonUk::Internal::ApiResponse.new
  end
end
