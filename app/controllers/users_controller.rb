class UsersController < ApplicationController
	def show
		@user = User.find(params[:id])
		@tab_active = params.key?(:tab_active) ? params[:tab_active] : nil
	end

	def new
		@user = User.new
	end

	def create
		@user = User.new(risk_params)
		if @user.save
			#成功処理
			flash[:success] = sprintf("ユーザー登録が完了しました。")
			redirect_to @user
		else
			render 'new'
		end
	end

	def update
		# TODO
	end

	private
		# ストロングパラメータ
		# @return [Hash] Userモデルを生成する為のパラメータハッシュ値
		def risk_params
			params.require(:user).permit(:nickname, :password, :password_confirmation)
		end
end
