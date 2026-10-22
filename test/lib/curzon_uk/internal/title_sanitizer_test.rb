require_relative '../../../test_helper'

class CurzonUk::Internal::TitleSanitizerTest < Minitest::Test
  def test_removes_dochouse_strand
    assert_sanitized 'Derek Vs Derek', 'DocHouse: Derek Vs Derek'
  end

  def test_removes_film_club_strand
    assert_sanitized 'Black Beyond: Welcome II The Terrordome',
                     'Film Club: Black Beyond: Welcome II The Terrordome'
  end

  def test_removes_film_year
    assert_sanitized 'Street Fighter', 'Street Fighter (2026)'
  end

  def test_keeps_titles_with_their_own_subtitles
    [
      'De Gaulle: Part 2- Liberte',
      'Ghosts: The Possession of Button House',
      'Hadestown: The Musical',
      'Fallen Angels by Noël Coward'
    ].each { |title| assert_sanitized title, title }
  end

  private

  def assert_sanitized(expected, title)
    assert_equal expected, CurzonUk::Internal::TitleSanitizer.new(title).sanitized
  end
end
