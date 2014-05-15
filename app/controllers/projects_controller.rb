class ProjectsController < ApplicationController

	before_action :signed_in_user

	def new
		@project = Project.new
		@project.user_id = current_user.id
	end

	def create
		@project = Project.new(project_params)
		@project.user_id = current_user.id
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
