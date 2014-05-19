module RiskHelper

	# Riskモデルのpriorityの値を表示文字列にする
	# @param [Fixnum] priority 優先度
	# @return [String] 表示用の優先度文字列
	def priority_to_str(priority)
		case priority
		when nil
			"未設定"
		when 0..2
			sprintf("%d(低)", priority)
		when 3..5
			sprintf("%d(中)", priority)
		when 6..9
			sprintf("%d(高)", priority)
		when 10
			sprintf("%d(最高)", priority)
		else
			"その他"
		end
	end

	# Riskモデルのpriorityの値をbootstrapの色文字列にする
	# @param [Fixnum] priority 優先度
	# @return [String] Bootstrapの色文字列
	def priority_to_bootstrap_level(priority)
		case priority
		when nil
			"default"
		when 0..2
			"default"
		when 3..5
			"info"
		when 6..9
			"danger"
		when 10
			"danger"
		else
			"default"
		end
	end
end