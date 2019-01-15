# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "admin?" do
    assert users(:komagata).admin?
    assert users(:machida).admin?
  end

  test "full_name" do
    assert_equal "Komagata Masaki", users(:komagata).full_name
  end

  test "active?" do
    travel_to Time.new(2014, 1, 1, 0, 0, 0) do
      assert users(:komagata).active?
    end

    travel_to Time.new(2014, 2, 2, 0, 0, 0) do
      assert_not users(:machida).active?
    end
  end

  test "twitter_account" do
    Bootcamp::Setup.attachment

    user = users(:komagata)
    user.twitter_account = ""
    assert user.valid?
    user.twitter_account = "azAZ_09"
    assert user.valid?
    user.twitter_account = "-"
    assert user.invalid?
    user.twitter_account = "あ"
    assert user.invalid?
    user.twitter_account = ":"
    assert user.invalid?
    user.twitter_account = "A" * 16
    assert user.invalid?
  end

  test "returns true when product of designated practice is checked" do
    assert users(:tanaka).has_checked_product_of?(practices(:practice_2))
  end

  test "returns false when product of designated practice isn't checked" do
    assert_not users(:tanaka).has_checked_product_of?(practices(:practice_3))
  end

  test "returns false when no product of designated practice" do
    assert_not users(:tanaka).has_checked_product_of?(practices(:practice_4))
  end

  test "total_learnig_time" do
    user = users(:hatsuno)
    assert_equal 0, user.total_learning_time

    report = Report.new(user_id: user.id, title: "test", reported_on: "2018-01-01", description: "test", wip: false)
    report.learning_times << LearningTime.new(started_at: "2018-01-01 00:00:00", finished_at: "2018-01-01 02:00:00")
    report.save!
    assert_equal 2, user.total_learning_time
  end

  test "dates_from_start_lerning" do
    user = users(:komagata)
    user.created_at = Time.new(2019, 1, 1, 0, 0, 0)
    travel_to Time.new(2020, 1, 1, 0, 0, 0) do
      assert_equal 365, user.dates_from_start_lerning
    end
  end

  test "order_by_reports_count" do
    @users = User.order_by_reports_count("desc")
    @names = @users.pluck(:login_name)
    assert @names == ["tanaka", "komagata", "machida", "yamada", "hajime", "yameo", "hatsuno", "kimura", "mineo"]
    @users = User.order_by_reports_count("asc")
    @names = @users.pluck(:login_name)
    assert @names == ["hajime", "hatsuno", "kimura", "mineo", "yameo", "machida", "yamada", "komagata", "tanaka"]
  end

  test "order_by_comments_count" do
    @users = User.order_by_comments_count("desc")
    @names = @users.pluck(:login_name)
    assert @names == ["komagata", "machida", "tanaka", "yamada", "mineo", "hajime", "yameo", "hatsuno", "kimura"]
    @users = User.order_by_comments_count("asc")
    @names = @users.pluck(:login_name)
    assert @names == ["yameo", "hatsuno", "kimura", "yamada", "mineo", "hajime", "machida", "tanaka", "komagata"]
  end
end
