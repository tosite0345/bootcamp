# frozen_string_literal: true

class CheckCallbacks
  def after_create(check)
    if check.sender != check.receiver
      NotificationFacade.checked(check)
    end

    if check.checkable_type == "Product"
      check.checkable.learning_complete
    end
  end
end
