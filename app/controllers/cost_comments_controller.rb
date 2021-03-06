class CostCommentsController < ApplicationController

	before_action :signed_in_user
	before_action :correct_user

	def create
		@saved_flag = @cost_comment.save # js用に変数に格納
		@cost_comment = CostComment.find_by_id(@cost_comment.id) #表示用にselectしなおす
		respond_to do |format|
			format.html { redirect_to risk_path(Risk.find(params[:cost_comment][:risk_id])) }
			format.js
		end
	end

	def destroy
		# 事前に対象のリスクを取得
		risk = @cost_comment.risk
		# 事前に削除対象のタイプを取得
		tab_type = @cost_comment.cost_type

		# 削除処理
		@cost_comment.destroy

		redirect_to(risk_path(risk, tab_type: tab_type))
	end

	private
		# アクションを行うユーザーが正しいかチェック
		def correct_user
			if params[:action] == 'create'
				@cost_comment = CostComment.new(cost_comment_params)
			else
				@cost_comment = CostComment.where(id: params[:id]).first
			end

			if @cost_comment.nil?
				flash[:warning] = "存在しないアドレスです"
				return redirect_to root_path
			end

			if !current_user?(@cost_comment.risk.project.user)
				flash[:danger] = "操作に対する権限がありません"
				return redirect_to root_path
			end
		end

		def cost_comment_params
			params.require(:cost_comment).permit(:cost_type, :comment, :cost_memo, :risk_id, :probability, :influence)
		end
end
