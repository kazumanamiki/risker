class ProjectsController < ApplicationController

	def index
	end

	def new
		@project = Project.new
	end

	def create
		# TODO プロジェクトIDをちゃんとしたものにする
		# TODO 作成者がプロジェクトの持ち主か確認する

		@project = Project.new(project_params)
		@project.user_id = 0 # TODO
		if @project.save
			#成功処理
			flash[:success] = sprintf("「%s」を追加しました。", @project.name)
			redirect_to @project
		else
			render 'new'
		end
	end

	def show
		@project = Project.find(params[:id])
	end

	private
		# ストロングパラメータ
		def project_params
			params.require(:project).permit(:name)
		end
end
