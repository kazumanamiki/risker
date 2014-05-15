class User < ActiveRecord::Base
	has_many :projects, dependent: :destroy
	has_many :comments, dependent: :destroy

	has_many :marked_comments, -> { where id_type: CommentModelHelper::CommentType::USER },
			foreign_key: "target_id", class_name: "Comment", dependent: :destroy

	before_save { self.nickname = nickname.downcase }
	before_create :create_remember_token

	has_secure_password

	CommentModelHelper.helper_build_comment CommentModelHelper::CommentType::USER

	validates_length_of :nickname, {
		minimum: 4,
		too_short: "ニックネームは4文字以上で入力してください",
		maximum: 30,
		too_long: "ニックネームは30文字以内で入力してください"
	}

	validates_uniqueness_of :nickname, {
		case_sensitive: false,
		message: "既に使われています"
	}

	validates_length_of :password, {
		minimum: 6,
		too_short: "パスワードは6文字以上で入力してください"
	}

	def self.new_remember_token
		SecureRandom.urlsafe_base64
	end

	def self.encrypt(token)
		Digest::SHA1.hexdigest(token.to_s)
	end

	private
		def create_remember_token
			self.remember_token = User.encrypt(User.new_remember_token)
		end

end
