module SessionsHelper

	# サインイン処理
	# @param [User] user サインインするユーザーモデル
	def sign_in(user)
		remember_token = User.new_remember_token
		cookies.permanent[:remember_token] = remember_token
		user.update_attribute(:remember_token, User.encrypt(remember_token))
		self.current_user = user
	end

	# サインイン確認
	# @return [boolean] サインインしていればtrue
	def signed_in?
		!current_user.nil?
	end

	# カレントユーザーの設定
	# @param [User] カレントユーザー
	def current_user=(user)
		@current_user = user
	end

	# カレントユーザーの取得
	# @return [User] カレントユーザー
	def current_user
		if @current_user.nil?
			remember_token = User.encrypt(cookies[:remember_token])
			@current_user ||= User.find_by(remember_token: remember_token)
		end
		@current_user
	end

	# カレントユーザーの確認
	# @param [User] 確認するユーザーモデル
	# @return [boolean] カレントユーザーであればtrue
	def current_user?(user)
		user == current_user
	end

	# サインインしてなければサインインページへ飛ばす
	def signed_in_user
		unless signed_in?
			store_location
			redirect_to signin_url, flash: { info: "ログインしてください。" }
		end
	end

	# サインアウト処理
	def sign_out
		self.current_user = nil
		cookies.delete(:remember_token)
	end

	# リダイレクト処理を行う
	def redirect_back_or(default)
		redirect_to(session[:return_to] || default)
		session.delete(:return_to)
	end

	# リクエストURLをリダイレクト先に設定する
	def store_location
		session[:return_to] = request.url
	end

end