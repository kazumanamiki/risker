module CostCommentHelper
	include CostCommentModelHelper

	module MatterCommentDefinition
		TAB_TEXT = "顕在化時の問題"
		TABLE = [
			{ icon: "glyphicon glyphicon-warning-sign", text: "問題点", size: "" },
			{ icon: "", text: "発生率", size: "col-sm-2"},
			{ icon: "", text: "影響", size: "col-sm-2" },
			{ icon: "glyphicon glyphicon-euro", text: "コスト", size: "col-sm-2" }
		]
		ADD_TEXT = "顕在化時の問題の追加"
		ADD_BUTTON = "問題点の追加"
	end

	module MeasureCommentDefinition
		TAB_TEXT = "対策案"
		TABLE = [
			{ icon: "glyphicon glyphicon-file", text: "対策案", size: "" },
			{ icon: "glyphicon glyphicon-euro", text: "軽減コスト", size: "col-sm-3" }
		]
		ADD_TEXT = "対策案の追加"
		ADD_BUTTON = "対策案の追加"
	end

	# @param [Fixnum] type コストコメントの種別 (CostCommentType)
	# @return [Module] コストコメントのメッセージが格納されたモジュール
	def get_cost_comment_definition(type)
		case type
		when CostCommentType::MATTER
			return MatterCommentDefinition
		when CostCommentType::MEASURE
			return MeasureCommentDefinition
		end
	end

	# @param [Fixnum] probability 発生確率
	# @return [String] 発生確率の文字列
	def self.probability_to_str(probability)
		case probability
		when nil
			"未設定"
		when ProbabilityType::LOW
			"低"
		when ProbabilityType::MIDDLE
			"中"
		when ProbabilityType::HIGH
			"高"
		else
			"その他"
		end
	end

	# @param [Fixnum] influence 影響範囲
	# @return [String] 影響範囲の文字列
	def self.influence_to_str(influence)
		case influence
		when nil
			"未設定"
		when InfluenceType::LOW
			"低"
		when InfluenceType::MIDDLE
			"中"
		when InfluenceType::HIGH
			"高"
		else
			"その他"
		end
	end

	PROBABILITY_SELECT = [
		[probability_to_str(ProbabilityType::LOW),    ProbabilityType::LOW],
		[probability_to_str(ProbabilityType::MIDDLE), ProbabilityType::MIDDLE],
		[probability_to_str(ProbabilityType::HIGH),   ProbabilityType::HIGH]
	]

	INFLUENCE_SELECT = [
		[influence_to_str(InfluenceType::LOW),    InfluenceType::LOW],
		[influence_to_str(InfluenceType::MIDDLE), InfluenceType::MIDDLE],
		[influence_to_str(InfluenceType::HIGH),   InfluenceType::HIGH]
	]

end