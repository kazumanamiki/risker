class RisksController < ApplicationController
	include CostCommentHelper

	before_action :signed_in_user
	before_action :correct_user, only: [:create, :show, :update, :checking, :destroy]

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
		@risk.save
		flash[:success] = sprintf("リスクの状態を最新にしました")
		redirect_to risk_path(@risk)
	end

	def destroy
		project = @risk.project
		flash[:success] = sprintf("リスク「%s」を削除しました", @risk.title)

		@risk.destroy

		redirect_to project_path(project)
	end

	private
		# アクションを行うユーザーが正しいかチェック
		def correct_user
			# アクションでリスクモデルの取得方法を変える
			if params[:action] == 'create'
				@risk = Risk.new(create_risk_params)
			else
				@risk = Risk.where(id: params[:id]).first
			end

			# リスクが存在するかチェック
			if @risk.nil?
				flash[:warning] = "存在しないアドレスです"
				return redirect_to root_path
			end
			# 対象のリスクがユーザーのものかチェック（権限チェック）
			if !current_user?(@risk.project.user)
				flash[:danger] = "操作に対する権限がありません"
				return redirect_to root_path
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
