namespace :db do
	desc "データベース初期構築"
	task init: :environment do
		make_test_user
	end

	def make_test_user
		User.create!(nickname: "testuser", password: "hogehoge", password_confirmation: "hogehoge")
	end

end