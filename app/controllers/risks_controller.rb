class RisksController < ApplicationController
	include CostCommentModelHelper

	before_action :signed_in_user
	before_action :correct_user, only: [:create, :update, :checking]

	def new
		@project = Project.find(params[:project])
		@risk = Risk.new(project_id: @project.id)
	rescue ActiveRecord::RecordNotFound
		# Projectのレコードが存在しない場合のエラー
		flash[:warning] = sprintf("Projectが選択されていません。")
		redirect_to user_path(current_user)
	end

	def create
		if @risk.save
			flash[:success] = sprintf("「%s」を追加しました。", @risk.title)
			redirect_to @risk
		else
			render 'new'
		end
	end

	def show
		@risk = Risk.find(params[:id])
		@tab_type = tab_type
		@cost_comment_definition = get_cost_comment_definition(@tab_type)
	end

	def update
		@saved_flag = @risk.update_attributes(update_risk_params) # js用に変数に格納
		respond_to do |format|
			format.html { redirect_to risk_path(@risk) }
			format.js
		end
	end

	def checking
		@risk.touch
		respond_to do |format|
			format.html { redirect_to risk_path(@risk) }
			format.js
		end
	end

	private
		# アクションを行うユーザーが正しいかチェック
		def correct_user
			if params[:action] == 'create'
				@risk = Risk.new(create_risk_params)
			else
				@risk = Risk.find(params[:id])
			end
			unless current_user?(@risk.project.user)
				flash.now[:danger] = "操作に対する権限がありません"
				redirect_to(root_path)
			end
		end

		# ストロングパラメータ(新規用)
		# @return [Hash] Riskモデルを生成する為のパラメータハッシュ値
		def create_risk_params
			params.require(:risk).permit(:title, :details, :status, :check_cycle, :watch_over_date, :project_id)
		end

		# ストロングパラメータ(新規用)
		# @return [Hash] Riskモデルを更新する為のパラメータハッシュ値
		def update_risk_params
			params.require(:risk).permit(:title, :details, :status, :check_cycle, :watch_over_date)
		end

		# タブタイプの取得
		# @return [Fixnum] コストコメントのタイプ
		def tab_type
			ret = CostCommentType::MATTER
			ret = CostCommentType::MEASURE if params[:tab_type] && ( params[:tab_type].to_i == CostCommentType::MEASURE )
			ret
		end
end
