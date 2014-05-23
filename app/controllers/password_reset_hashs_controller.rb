class PasswordResetHashsController < ApplicationController

	def show
	end

	def create
		user = User.where(email: params[:email]).first
		if user.nil?
			# ユーザーが存在しない場合
			render 'notfound'
		else
			# リミット制限の確認
			if LimitApi.use_api?(:reset_email)
				hash_pass = PasswordResetHash.generate_reset_hash(user)

				# メール送信
				PasswordResetMailer.password_reset_email(user.nickname, user.email, hash_pass).deliver

				# メール送信ページ表示
				render 'sent'
			else
				# 制限オーバーページ表示
				render 'busy'
			end
		end
	end

	def edit
		reset_hash = PasswordResetHash.where(hash_pass: params[:hash]).first
		if reset_hash.nil? || !reset_hash.valid_hash?(Time.zone.now)
			# ハッシュが存在しない or 期限切れ の場合（不正アクセス）
			render 'overdue'
		else
			# ハッシュが有効な場合はユーザーを特定
			@hash = params[:hash]
			@user = reset_hash
		end
	end

	def update
		prh = PasswordResetHash.where(hash_pass: params[:hash]).first
		if prh.nil? || !prh.valid_hash?(Time.zone.now)
			# 有効期限切れ
			render 'password_reset_hashs/overdue'
		else
			# ユーザーを取得してパスワードを更新する
			user = prh.user
			if user.update(pwreset_params)
				# ハッシュ値を無効にする
				PasswordResetHash.disable_reset_hash(user)
				# パスワードリセット完了のページ表示
			else
				# 再表示
				@hash = params[:hash]
				@user = user
				render 'password_reset_hashs/edit'
			end
		end
	end


	private
		# ストロングパラメータ(パスワードリセット)
		def pwreset_params
			params.require(:user).permit(:password, :password_confirmation)
		end
end
