class SessionsController < ApplicationController

	def new
	end

	def create
		user = User.find_by(email: params[:email].downcase)
		if user && user.authenticate(params[:password])
			sign_in user
			redirect_back_or user
			flash.now[:info] = 'ログインしました。'
		else
			flash.now[:danger] = 'ニックネームとパスワードが一致しません。'
			render 'new'
		end
	end

	def destroy
		sign_out
		flash.now[:info] = 'ログアウトしました。'
		redirect_to root_url
	end

end
