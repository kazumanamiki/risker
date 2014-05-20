class ProjectsController < ApplicationController

	before_action :signed_in_user
	before_action :correct_user, only: [:destroy]

	def new
		@project = Project.new
		@project.user_id = current_user.id
	end

	def create
		@project = current_user.projects.build(project_params)
		if @project.save
			#成功処理
			flash[:success] = sprintf("「%s」を追加しました", @project.name)
			redirect_to @project
		else
			render 'new'
		end
	end

	def show
		@project = Project.find(params[:id])
	end

	def destroy
		flash[:success] = sprintf("プロジェクト「%s」を削除しました", @project.name)

		@project.destroy

		redirect_to root_path
	end

	private
		# アクションを行うユーザーが正しいかチェック
		def correct_user
			@project = Project.find(params[:id])
			unless current_user?(@project.user)
				flash[:danger] = "操作に対する権限がありません"
				redirect_to root_path
			end
		end

		# ストロングパラメータ
		def project_params
			params.require(:project).permit(:name)
		end
end
