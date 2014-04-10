class Project < ActiveRecord::Base
	has_many :risks,  dependent: :destroy
	belongs_to :user

	has_many :marked_comments, -> { where id_type: CommentModelHelper::CommentType::PROJECT },
			foreign_key: "target_id", class_name: "Comment", dependent: :destroy

	CommentModelHelper.helper_build_comment CommentModelHelper::CommentType::PROJECT

	validates_presence_of :name, {
		message: "プロジェクト名を空にはできません"
	}

	validates_length_of :name, {
		maximum: 30,
		too_long: "プロジェクト名は30文字以内で入力してください"
	}

	validates_presence_of :user_id
end
