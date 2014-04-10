class Comment < ActiveRecord::Base

	validates_presence_of :user_id, {
		message: "ユーザーIDを空にはできません"
	}

	validates_presence_of :comment, {
		message: "コメントを空にはできません"
	}

	validates_length_of :comment, {
		maximum: 300,
		too_long: "コメントは300文字以内で入力してください"
	}

	validates_presence_of :id_type, {
		message: "コメント種別を空にはできません"
	}

	validates_presence_of :target_id, {
		message: "ターゲットIDを空にはできません"
	}

end
