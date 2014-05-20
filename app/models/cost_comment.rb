class CostComment < ActiveRecord::Base
	include CostCommentModelHelper

	belongs_to :risk

	has_many :marked_comments, -> { where id_type: CommentModelHelper::CommentType::COST_COMMENT },
			foreign_key: "target_id", class_name: "Comment", dependent: :destroy

	CommentModelHelper.helper_build_comment CommentModelHelper::CommentType::COST_COMMENT


	default_scope -> { order('priority DESC') }


	before_save :calc_priority
	after_save :update_risk_priority
	after_destroy :update_risk_priority


	validates_presence_of :cost_type, {
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

	validates_numericality_of :probability, {
		only_integer: true,
		allow_nil: true,
		greater_than_or_equal_to: 1,
		less_than_or_equal_to: 3,
		message: "発生率は低,中,高で入力してください"
	}

	validates_numericality_of :influence, {
		only_integer: true,
		allow_nil: true,
		greater_than_or_equal_to: 1,
		less_than_or_equal_to: 3,
		message: "影響は低,中,高で入力してください"
	}

	validates_numericality_of :priority, {
		only_integer: true,
		allow_nil: true,
		greater_than_or_equal_to: 1,
		less_than_or_equal_to: 10,
		message: "優先度は1〜10の間で整数で入力してください"
	}

	validates_presence_of :risk_id

	private
		# priorityが設定されていなければ計算する
		def calc_priority
			if !self.probability.nil? || !self.influence.nil?
				# どちらか片方が設定されていれば優先度を設定
				val_probability = self.probability.nil? ? 1 : self.probability
				val_influence = self.influence.nil? ? 1 : self.influence
				self.priority = val_probability * val_influence

			elsif self.probability.nil? && self.influence.nil?
				#両方ともnilであれば優先度もnil
				self.priority = nil
			end
		end

		# 関連するリスクのプライオリティを更新します
		def update_risk_priority
			risk = Risk.find_by_id(self.risk_id)
			risk.save unless risk.nil?
		end
end
