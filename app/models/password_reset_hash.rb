class PasswordResetHash < ActiveRecord::Base

	belongs_to :user
	default_scope -> { order('updated_at DESC') }

	before_validation :create_reset_hash

	validates :user_id, presence: true, uniqueness: { case_sensitive: false }
	validates :hash_pass, presence: true
	validates :enable_flag, inclusion: { in: [true, false] }

	# 指定の時間が有効期限内か調べる
	# @param [DateTime] datetime チェックする日時
	# @return [boolean] 有効期限内であればtrue
	def valid_hash?(datetime)
		self.enable_flag? && (self.updated_at > (datetime - 1.hour))
	end

	# 指定のユーザーのハッシュ値を生成する
	# @param [User] user ハッシュ値を生成するユーザー
	# @return [String] ハッシュ値
	def self.generate_reset_hash(user)
		reset_hash = where(user_id: user.id).first_or_create
		reset_hash.enable_flag = true
		reset_hash.save
		return reset_hash.hash_pass
	end

	def self.disable_reset_hash(user)
		reset_hash = where(user_id: user.id).first
		reset_hash.update(enable_flag: false) unless reset_hash.nil?
	end

	private
		# 保存前にハッシュ値を生成する
		def create_reset_hash
			reset_user = self.user
			self.hash_pass = make_hash_pass(reset_user.email) unless reset_user.nil?
		end

		# キーワードを元にセキュアなハッシュ値を生成
		# @param [String] keyword 指定のキーワード
		# @return [String] ハッシュ文字列
		def make_hash_pass(keyword)
			secure_digest(Time.now, (1..10).map{ rand.to_s }, keyword)
		end

		# 引数をもとにSHA1でハッシュ値を生成
		# @param [Array] ハッシュ値生成元の配列
		# @return [String] ハッシュ文字列
		def secure_digest(*args)
			Digest::SHA1.hexdigest(args.flatten.join('--'))
		end

end
