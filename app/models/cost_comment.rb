class CostComment < ActiveRecord::Base
	belongs_to :risk

	has_many :marked_comments, -> { where id_type: CommentModelHelper::CommentType::COST_COMMENT },
			foreign_key: "target_id", class_name: "Comment", dependent: :destroy

	CommentModelHelper.helper_build_comment CommentModelHelper::CommentType::COST_COMMENT

	validates_presence_of :type, {
		message: "種別を空にはできません"
	}

	validates_presence_of :comment, {
		message: "コメントを空にはできません"
	}
	validates_length_of :comment, {
		maximum: 300,
		too_long: "コメントは300文字以内で入力してください"
	}

	validates_length_of :cost_memo, {
		maximum: 300,
		too_long: "コストメモは300文字以内で入力してください"
	}

	validates_presence_of :risk_id
end
