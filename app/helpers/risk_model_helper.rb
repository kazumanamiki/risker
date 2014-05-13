module RiskModelHelper

	module StatusType
		# 未発生
		UNCONFIRMED = 0
		# 潜在化
		LATENT = 1
		# 顕在化
		APPARENT = 2
		# 消滅
		EXTINCTION = 3
	end

	# @param [Fixnum] type 種別(StatusType)
	# @return [String] 種別に対応した文字列
	def self.type_to_s(type)
		case type
		when StatusType::UNCONFIRMED
			"未発生"
		when StatusType::LATENT
			"潜在化"
		when StatusType::APPARENT
			"顕在化"
		when StatusType::EXTINCTION
			"消滅"
		end
	end

	RISK_TYPE_SELECT = [
		[self.type_to_s(StatusType::UNCONFIRMED), StatusType::UNCONFIRMED],
		[self.type_to_s(StatusType::LATENT), StatusType::LATENT],
		[self.type_to_s(StatusType::APPARENT), StatusType::APPARENT],
		[self.type_to_s(StatusType::EXTINCTION), StatusType::EXTINCTION]
	]

end
