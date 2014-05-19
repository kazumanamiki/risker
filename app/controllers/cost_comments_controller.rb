class CostCommentsController < ApplicationController

	before_action :signed_in_user
	before_action :correct_user, only: [:create]

	def create
		@saved_flag = @cost_comment.save # js用に変数に格納
		@cost_comment = CostComment.find_by_id(@cost_comment.id) #表示用にselectしなおす
		respond_to do |format|
			format.html { redirect_to risk_path(Risk.find(params[:cost_comment][:risk_id])) }
			format.js
		end
	end

	private
		# アクションを行うユーザーが正しいかチェック
		def correct_user
			if params[:action] == 'create'
				@cost_comment = CostComment.new(cost_comment_params)
			else
				@cost_comment = CostComment.find(params[:id])
			end
			unless current_user?(@cost_comment.risk.project.user)
				flash.now[:danger] = "操作に対する権限がありません"
				redirect_to(root_path)
			end
		end

		def cost_comment_params
			params.require(:cost_comment).permit(:cost_type, :comment, :cost_memo, :risk_id, :probability, :influence)
		end
end
