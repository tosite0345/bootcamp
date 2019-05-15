# frozen_string_literal: true

class WatchesController < ApplicationController
  include Rails.application.routes.url_helpers

  def create
    @watch = Watch.new(
      user: current_user,
      watchable: watchable
    )

    @watch.save!
    redirect_back fallback_location: root_path,
      notice: "【 #{watchable.title} 】をウォッチ対象に登録しました。"
  end

  def destroy
    @watch = Watch.find_by(watchable_id: params[:id], user_id: current_user.id)
    @watch.destroy
    redirect_to @watch.watchable, notice: "ウォッチを止めました"
  end

  private
    def watch_params
      params.require(:watch).permit(
        :watchable_id,
        :watchable_type
      )
    end

    def watchable
      if params[:report_id]
        Report.find(params[:report_id])
      elsif params[:product_id]
        Product.find(params[:product_id])
      elsif params[:question_id]
        Question.find(params[:question_id])
      end
    end
end