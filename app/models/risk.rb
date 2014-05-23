class Risk < ActiveRecord::Base
	include RiskModelHelper

	has_many :cost_comments, dependent: :destroy
	has_many :matter_comments, -> { where cost_type: CostCommentModelHelper::CostCommentType::MATTER },
			class_name: "CostComment"
	has_many :measure_comments, -> { where cost_type: CostCommentModelHelper::CostCommentType::MEASURE },
			class_name: "CostComment"

	belongs_to :project

	has_many :marked_comments, -> { where id_type: CommentModelHelper::CommentType::RISK },
			foreign_key: "target_id", class_name: "Comment", dependent: :destroy

	before_save :create_next_check_date
	before_save :calc_priority

	CommentModelHelper.helper_build_comment CommentModelHelper::CommentType::RISK

	validates_presence_of :title, {
		message: "タイトルを空にはできません"
	}

	validates_length_of :title, {
		maximum: 30,
		too_long: "タイトルは30文字以内で入力してください"
	}

	validates_length_of :details, {
		maximum: 300,
		too_long: "詳細は300文字以内で入力してください"
	}

	validates_numericality_of :check_cycle, {
		only_integer: true,
		allow_nil: false,
		greater_than_or_equal_to: 0,
		less_than_or_equal_to: 24 * 7 * 4,
		message: "チェックサイクルは0〜#{24 * 7 * 4}の間で整数で入力してください"
	}

	validates_numericality_of :priority, {
		only_integer: true,
		allow_nil: true,
		greater_than_or_equal_to: 1,
		less_than_or_equal_to: 10,
		message: "優先度は1〜10の間で整数で入力してください"
	}

	validates_presence_of :watch_over_date, {
		message: "監視終了日時を空にはできません"
	}

	validates_presence_of :project_id


	# ----- 検索用SQL

	SQL_AND = " and "
	SQL_CHECK_WATCH_OVER_DATE = "(watch_over_date >= :datetime)"
	SQL_CHECK_NEXT_DATE       = "(next_check_date < :datetime)"
	SQL_CHECK_NEXT_DATE_NULL  = "(next_check_date is not :null)"
	SQL_CHECK_STATUS          = "(status <> :extinction)"


	# ----- 検索用クラスメソッド

	# プロジェクトのリスクを次回チェック日でソートして取得
	# @params [Project] project 検索対象のプロジェクト
	# @return [ActiveRecord] アクティブレコード
	def self.from_projects_check_date_oder(project, params = {})
		sql_where = "project_id = :project_id"
		sql_where << SQL_AND << SQL_CHECK_WATCH_OVER_DATE
		sql_where << SQL_AND << SQL_CHECK_NEXT_DATE_NULL
		sql_where << SQL_AND << SQL_CHECK_STATUS

		where_hash = generate_where_hash
		where_hash.merge!(params)
		where_hash[:project_id] = project.id

		ar = where(sql_where, where_hash)
		ar = ar.order("next_check_date")
		ar
	end

	# プロジェクトに対してチェック日時が過ぎているリスクを取得する
	# @params [Project] project 検索対象のプロジェクト
	# @return [ActiveRecord] アクティブレコード
	def self.from_projects_primary_check_by(project, params = {})
		sql_where = "project_id = :project_id"
		sql_where << SQL_AND << SQL_CHECK_WATCH_OVER_DATE
		sql_where << SQL_AND << SQL_CHECK_NEXT_DATE
		sql_where << SQL_AND << SQL_CHECK_STATUS

		where_hash = generate_where_hash
		where_hash.merge!(params)
		where_hash[:project_id] = project.id

		where(sql_where, where_hash)
	end

	# ユーザーに対してチェック日時が過ぎているリスクを取得する
	# @params [Project] project 検索対象のプロジェクト
	# @return [ActiveRecord] アクティブレコード
	def self.from_users_primary_check_by(user, params = {})
		users_project_ids = "select id from projects where user_id = :user_id"
		sql_where = "project_id IN (#{users_project_ids})"
		sql_where << SQL_AND << SQL_CHECK_WATCH_OVER_DATE
		sql_where << SQL_AND << SQL_CHECK_NEXT_DATE
		sql_where << SQL_AND << SQL_CHECK_STATUS

		where_hash = generate_where_hash
		where_hash.merge!(params)
		where_hash[:user_id] = user.id

		where(sql_where, where_hash)
	end


	# ---- インスタンスメソッド

	def next_check_date_text
		return "なし" if next_check_date.nil?
		return "監視期限切れ" if watch_over_date < Time.zone.now
		return next_check_date.strftime("%Y-%-m-%-d %-H時")
	end


	# ---- privateメソッド

	private
		# レコードの保存の際にnext_check_dateを決定する
		# @note チェック周期が0の場合はnext_check_dataを0にしてチェック対象から外す
		def create_next_check_date
			if (self.check_cycle == 0)
				self.next_check_date = nil
			else
				self.next_check_date = Time.zone.now.since(60 * 60 * self.check_cycle)
			end
		end

		# レコードの保存の際に優先度をCostCommentから取得し決定する
		def calc_priority
			self.priority = self.matter_comments.maximum(:priority)
		end

		# whereで使用するhashパラメータの初期値生成
		# @return [Hash] where句で使用するhashパラメータ
		def self.generate_where_hash
			ret = {}
			ret[:datetime] = Time.zone.now
			ret[:extinction] = StatusType::EXTINCTION.to_s
			ret[:null] = nil
			ret
		end
end
