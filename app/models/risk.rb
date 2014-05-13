class Risk < ActiveRecord::Base
	has_many :cost_comments, dependent: :destroy
	has_many :matter_comments, -> { where cost_type: CostCommentModelHelper::CostCommentType::MATTER },
			class_name: "CostComment"
	has_many :measure_comments, -> { where cost_type: CostCommentModelHelper::CostCommentType::MEASURE },
			class_name: "CostComment"

	belongs_to :project

	has_many :marked_comments, -> { where id_type: CommentModelHelper::CommentType::RISK },
			foreign_key: "target_id", class_name: "Comment", dependent: :destroy

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

	validates_presence_of :watch_over_date, {
		message: "監視終了日時を空にはできません"
	}

	validates_presence_of :project_id
end
