class CostCommentsController < ApplicationController
	def create
		# TODO リスクに対して自分がアクセス権を有しているかチェックする(不正アクセス対策)

		@cost_comment = CostComment.new(cost_comment_params)
		@saved_flag = @cost_comment.save # js用に変数に格納

		if @saved_flag
			# 成功処理
			flash.now[:success] = "コメントを追加しました" # TODO 文言はcost_typeにより変わる
		else
			# 失敗処理
			flash.now[:error] = "コメント追加に失敗しました" # TODO 文言はcost_typeにより変わる
		end

		respond_to do |format|
			format.html { redirect_to Risk.find(params[:cost_comment][:risk_id]) }
			format.js
		end
	end

	private
		def cost_comment_params
			params.require(:cost_comment).permit(:cost_type, :comment, :cost_memo, :risk_id)
		end
end
