class PasswordResetMailer < ActionMailer::Base
	default from: "notify@risker.info"

	def password_reset_email(nickname, email, reset_path)
		@nickname = nickname
		@reset_path = reset_path

		mail to: email, subject: "Risker パスワードリセットのご連絡"
	end
end
