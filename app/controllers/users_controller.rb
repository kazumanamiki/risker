class UsersController < ApplicationController

	before_action :signed_in_user, only: [:show, :edit, :update, :destroy]
	before_action :correct_user, only: [:edit, :update]

	def new
		@user = User.new
	end

	def create
		@user = User.new(user_params)
		if @user.save
			sign_in @user
			flash[:success] = sprintf("ユーザー登録が完了しました。")
			redirect_to @user
		else
			render 'new'
		end
	end

	def show
		@user = User.find(params[:id])
		@tab_active = params.key?(:tab_active) ? params[:tab_active] : nil

	rescue ActiveRecord::RecordNotFound
		# Userのレコードが存在しない場合のエラー
		flash[:warning] = sprintf("指定のユーザーは存在しません。")
		redirect_to user_path(current_user)
	end

	def update
		# TODO
	end

	private
		# ストロングパラメータ(ユーザー作成)
		# @return [Hash] Userモデルを生成する為のパラメータハッシュ値
		def user_params
			params.require(:user).permit(:nickname, :email, :password, :password_confirmation)
		end

		def correct_user
			@user = User.find(params[:id])
			redirect_to(root_path) unless correct_user?(@user)
		end
end
