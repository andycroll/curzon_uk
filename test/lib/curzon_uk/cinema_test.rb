require_relative '../../test_helper'

class CurzonUk::CinemaTest < Minitest::Test
  def setup
    @api_response = FakeApiResponse.new
  end

  def test_new_upcases_id
    assert_equal 'SOH1', CurzonUk::Cinema.new('soh1').id
  end

  def test_all_returns_cinemas
    with_fake_api do
      cinemas = CurzonUk::Cinema.all

      assert(cinemas.all? { |cinema| cinema.instance_of?(CurzonUk::Cinema) })
      assert_equal %w(CAN2 SOH1 VIC1), cinemas.map(&:id)
    end
  end

  def test_adr_strips_line_commas
    expected = {
      street_address:   '99 Example Avenue',
      extended_address: nil,
      locality:         'London',
      region:           nil,
      postal_code:      'W1D 0ZZ',
      country_name:     'United Kingdom'
    }

    with_fake_api do
      assert_equal expected, CurzonUk::Cinema.new('SOH1').adr
      assert_equal expected, CurzonUk::Cinema.new('SOH1').address
    end
  end

  def test_adr_with_town_and_postcode_on_one_line
    with_fake_api do
      adr = CurzonUk::Cinema.new('CAN2').adr

      assert_equal 'Unit 9', adr[:street_address]
      assert_equal 'The Example Riverside', adr[:extended_address]
      assert_equal 'Canterbury', adr[:locality]
      assert_equal 'CT1 0ZZ', adr[:postal_code]
    end
  end

  def test_adr_trims_postcode
    with_fake_api do
      assert_equal 'SW1E 0ZZ', CurzonUk::Cinema.new('VIC1').postal_code
    end
  end

  def test_brand_and_full_name
    with_fake_api do
      assert_equal 'Curzon', CurzonUk::Cinema.new('SOH1').brand
      assert_equal 'Curzon Soho', CurzonUk::Cinema.new('SOH1').full_name
    end
  end

  def test_name
    with_fake_api do
      assert_equal 'Soho', CurzonUk::Cinema.new('SOH1').name
    end
  end

  def test_slug
    with_fake_api do
      assert_equal 'curzon-soho', CurzonUk::Cinema.new('SOH1').slug
    end
  end

  def test_url
    with_fake_api do
      assert_equal 'https://www.curzon.com/venues/soho/', CurzonUk::Cinema.new('SOH1').url
    end
  end

  private

  def with_fake_api(&block)
    CurzonUk::Internal::ApiResponse.stub(:new, @api_response, &block)
  end
end
