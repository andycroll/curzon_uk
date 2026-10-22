require_relative '../../test_helper'

class CurzonUk::PerformanceTest < Minitest::Test
  DATE = Date.new(2026, 10, 24)

  def setup
    @api_response = FakeApiResponse.new
  end

  def test_at_returns_performances
    performances = performances_at('SOH1')

    assert(performances.all? { |p| p.instance_of?(CurzonUk::Performance) })
    assert_equal 5, performances.count
  end

  def test_at_accepts_lower_case_id
    assert_equal 5, performances_at('soh1').count
  end

  def test_at_sets_cinema_details
    performances = performances_at('SOH1')

    assert_equal ['SOH1'], performances.map(&:cinema_id).uniq
    assert_equal ['Soho'], performances.map(&:cinema_name).uniq
  end

  def test_at_parses_first_performance
    performance = performances_at('SOH1').first

    assert_equal 'The Example Film', performance.film_name
    assert_equal Time.utc(2026, 10, 24, 12, 0), performance.starting_at
    assert_equal '2d', performance.dimension
    assert_equal [], performance.variant
    assert_equal 'https://www.curzon.com/ticketing/seats/?showtimeId=SOH1-1001', performance.booking_url
  end

  def test_at_parses_3d_open_captions
    performance = performances_at('SOH1')[1]

    assert_equal '3d', performance.dimension
    assert performance.subtitled?
  end

  def test_at_strips_strand_and_year
    performance = performances_at('SOH1')[2]

    assert_equal 'A Made Up Documentary', performance.film_name
    assert_equal 2025, performance.film_year
    assert_equal %w(q&a), performance.variant
  end

  def test_at_strips_film_club
    performance = performances_at('SOH1')[3]

    assert_equal 'Pretend Classic', performance.film_name
    assert_equal %w(baby), performance.variant
  end

  def test_at_moves_festival_from_title
    performance = performances_at('SOH1')[4]

    assert_equal 'Imaginary Picture', performance.film_name
    assert_equal Cinebase::Festival.new(name: 'UKJFF', year: 2026), performance.festival
  end

  def test_at_keeps_after_midnight_on_next_utc_day
    assert_equal Time.utc(2026, 10, 24, 23, 15), performances_at('SOH1').last.starting_at
  end

  def test_at_requests_each_date_in_range
    to = DATE + 2

    with_fake_api { CurzonUk::Performance.at('SOH1', from: DATE, to: to) }

    assert_equal (DATE..to).to_a, @api_response.requested_dates
  end

  def test_at_rejects_range_ending_before_start
    assert_raises(ArgumentError) { CurzonUk::Performance.at('SOH1', from: DATE, to: DATE - 1) }
  end

  def test_new_sets_defaults
    performance = CurzonUk::Performance.new(
      film_name: 'Carol', cinema_id: 'SOH1', cinema_name: 'Soho',
      starting_at: Time.utc(2013, 9, 12, 11, 0)
    )

    assert_nil performance.booking_url
    assert_equal '2d', performance.dimension
    assert_nil performance.festival
    assert_nil performance.film_year
    refute performance.subtitled?
    assert_equal [], performance.variant
  end

  private

  def performances_at(cinema_id)
    with_fake_api { CurzonUk::Performance.at(cinema_id, from: DATE, to: DATE) }
  end

  def with_fake_api(&block)
    CurzonUk::Internal::ApiResponse.stub(:new, @api_response, &block)
  end
end
