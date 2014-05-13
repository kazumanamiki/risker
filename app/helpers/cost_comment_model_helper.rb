module CostCommentModelHelper
	module CostCommentType
		MATTER = 0
		MEASURE = 1
	end

	module MatterCommentDefinition
		TAB_TEXT = "顕在化時の問題"
		TABLE_TEXT = [
			"問題点",
			"コスト"
		]
		ADD_TEXT = "顕在化時の問題の追加"
		ADD_BUTTON = "問題点の追加"
	end

	module MeasureCommentDefinition
		TAB_TEXT = "対策案"
		TABLE_TEXT = [
			"対策案",
			"軽減コスト"
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
end