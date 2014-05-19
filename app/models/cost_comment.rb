class CostComment < ActiveRecord::Base
	include CostCommentModelHelper

	belongs_to :risk

	has_many :marked_comments, -> { where id_type: CommentModelHelper::CommentType::COST_COMMENT },
			foreign_key: "target_id", class_name: "Comment", dependent: :destroy

	default_scope -> { order('priority DESC') }

	before_save :calc_priority
	after_save :update_risk_priority

	CommentModelHelper.helper_build_comment CommentModelHelper::CommentType::COST_COMMENT

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

	validates_presence_of :risk_id

	def self.from_risks_matter_max_priority_by(risk)
		where_hash = { risk_id: risk.id, cost_type: CostCommentType::MATTER }
		where("risk_id = :risk_id and cost_type = :cost_type", where_hash).maximum(:priority)
	end

	private
		# priorityが設定されていなければ計算する
		def calc_priority
			# 発生確率、影響度が設定されており、優先度が設定されていなければ自動計算
			if (!self.probability.nil? && !self.influence.nil?) && self.priority.nil?
				self.priority = self.probability * self.influence
			end
		end

		# 関連するリスクのプライオリティを更新します
		def update_risk_priority
			risk = Risk.find_by_id(self.risk_id)
			# 空セーブ（Riskモデルで最新状態にする）
			risk.save unless risk.nil?
		end
end
