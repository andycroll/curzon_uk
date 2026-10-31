require_relative 'live_helper'

class LiveCinemaTest < Minitest::Test
  def test_all_returns_cinemas
    cinemas = CurzonUk::Cinema.all

    assert(cinemas.all? { |cinema| cinema.instance_of?(CurzonUk::Cinema) })
    assert_operator cinemas.size, :>, 10
    assert_equal 'Soho', cinemas.detect { |cinema| cinema.id == 'SOH1' }.name
  end

  def test_every_cinema_has_a_postcode
    CurzonUk::Cinema.all.each do |cinema|
      refute_empty cinema.postal_code, "#{cinema.id} #{cinema.name}"
    end
  end

  def test_cinemas_have_uk_coordinates
    located = CurzonUk::Cinema.all.select(&:latitude)

    refute_empty located
    located.each do |cinema|
      assert_includes 49.0..61.0, cinema.latitude, "#{cinema.id} #{cinema.name}"
      assert_includes(-9.0..2.0, cinema.longitude, "#{cinema.id} #{cinema.name}")
    end
  end
end

class LivePerformanceTest < Minitest::Test
  def test_at_returns_performances
    tomorrow = Date.today + 1
    performances = CurzonUk::Performance.at('SOH1', from: tomorrow, to: tomorrow)

    assert(performances.all? { |p| p.instance_of?(CurzonUk::Performance) })
    assert_operator performances.count, :>, 3
  end
end
