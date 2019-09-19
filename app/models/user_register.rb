# frozen_string_literal: true

class UserRegister
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def create(params, stripe_token, param_training)
    @user.attributes = params
    @user.company = Company.first
    @user.course = Course.first

    if param_training == "true"
      @user.free = true
      @user.trainee = true
    end

    begin
      @user.with_lock do
        @user.save

        customer = Card.create(@user, stripe_token)
        subscription = Subscription.create(customer["id"])

        if @user.card?
          flash[:alert] = "既にカード登録済みです。"
          logger.warn "既にカード登録済みです。"
          raise "既にカード登録済みです。"
        else
          @user.update!(
            customer_id: customer["id"],
            subscription_id: subscription["id"]
          )
        end
      end

      logger.info "[Payment] カードを登録しました。"
    rescue Stripe::CardError => e
      @user.update!(customer_id: nil)
      flash[:alert] = "カード情報に不備があります。：#{e.message}"
      logger.warn "[Payment] カード情報に不備があります。：#{e.message}"
    rescue => e
      @user.update!(customer_id: nil)
      flash[:alert] = "カード登録に失敗しました。運営会社までお問い合わせください。：#{e.message}"
      logger.warn "[Payment] カード登録に失敗しました。運営会社までお問い合わせください。：#{e.message}"
    end
  end
end
