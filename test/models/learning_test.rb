# frozen_string_literal: true

require "test_helper"

class LearningTest < ActiveSupport::TestCase
  test "change status" do
    learning = learnings(:learning_1)
    learning.change_status("submitted")
    assert_equal learning.status, "submitted"

    learning = learnings(:learning_1)
    learning.change_status("complete")
    assert_equal learning.status, "complete"
  end

  test "valid is_startable_practice" do
    learning = learnings(:learning_3)
    assert learning.valid?

    learning.status = "started"
    assert_not learning.valid?
  end
end
