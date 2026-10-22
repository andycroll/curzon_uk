require_relative '../../../../../test_helper'

class CurzonUk::Internal::Parser::Api::ShowtimeTest < Minitest::Test
  FILMS = {
    'HO1' => { 'title' => { 'text' => 'Sense and Sensibility (2026)' } },
    'HO2' => { 'title' => { 'text' => 'UKJFF - Example Gala' } }
  }.freeze

  ATTRIBUTES = {
    '1' => { 'shortName' => { 'text' => 'Captioned' }, 'name' => { 'text' => 'Open Captioned' } },
    '2' => { 'shortName' => { 'text' => 'Baby Club' }, 'name' => { 'text' => 'Baby Club' } },
    '3' => { 'shortName' => { 'text' => 'Q&A' }, 'name' => { 'text' => 'Screening followed by a Q&A' } },
    '4' => { 'shortName' => { 'text' => 'Atmos' }, 'name' => { 'text' => 'Atmos' } }
  }.freeze

  def test_to_hash
    expected = {
      booking_url: 'https://www.curzon.com/ticketing/seats/?showtimeId=SOH1-1',
      dimension: '2d',
      festival: nil,
      film_name: 'Sense and Sensibility',
      film_year: 2026,
      starting_at: Time.utc(2026, 10, 24, 17, 30),
      variant: []
    }

    assert_equal expected, parse
  end

  def test_3d_glasses
    assert_equal '3d', parse(requires3d: true)[:dimension]
  end

  def test_maps_attribute_names_to_variants
    assert_equal %w(subtitled baby q&a), parse(attribute_ids: %w(1 2 3 4))[:variant]
  end

  def test_festival
    showtime = parse(film_id: 'HO2')

    assert_equal Cinebase::Festival.new(name: 'UKJFF', year: 2026), showtime[:festival]
    assert_equal 'Example Gala', showtime[:film_name]
  end

  private

  def parse(attribute_ids: [], requires3d: false, film_id: 'HO1')
    data = {
      'id' => 'SOH1-1',
      'filmId' => film_id,
      'schedule' => { 'startsAt' => '2026-10-24T18:30:00+01:00' },
      'attributeIds' => attribute_ids,
      'requires3dGlasses' => requires3d
    }
    CurzonUk::Internal::Parser::Api::Showtime.new(
      data, films: FILMS, attributes: ATTRIBUTES
    ).to_hash
  end
end
