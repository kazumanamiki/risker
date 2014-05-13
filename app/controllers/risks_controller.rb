class RisksController < ApplicationController
	include CostCommentModelHelper

	def new
		@project = Project.find(params[:project])
		@risk = Risk.new(project_id: @project.id)
	rescue ActiveRecord::RecordNotFound
		# Projectのレコードが存在しない場合のエラー
		flash[:warning] = sprintf("Projectが選択されていません。")
		redirect_to root_path # TODO ログインユーザーページへ飛ぶようにする
	end

	def create
		# TODO 作成対象のプロジェクトが許可対象のものか確認する

		@risk = Risk.new(risk_params)
		if @risk.save
			#成功処理
			flash[:success] = sprintf("「%s」を追加しました。", @risk.title)
			redirect_to @risk
		else
			@project = @risk.project
			render 'new'
		end
	end

	def show
		@risk = Risk.find(params[:id])
		@tab_type = tab_type
		@cost_comment_definition = get_cost_comment_definition(@tab_type)
	end

	private
		# ストロングパラメータ
		# @return [Hash] Riskモデルを生成する為のパラメータハッシュ値
		def risk_params
			params.require(:risk).permit(:title, :details, :status, :check_cycle, :watch_over_date, :project_id)
		end

		# タブタイプの取得
		# @return [Fixnum] コストコメントのタイプ
		def tab_type
			ret = CostCommentType::MATTER
			ret = CostCommentType::MEASURE if params[:tab_type] && ( params[:tab_type].to_i == CostCommentType::MEASURE )
			ret
		end
end
