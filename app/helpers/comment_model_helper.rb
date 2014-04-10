module CommentModelHelper
	module CommentType
		USER = 0
		PROJECT = 1
		RISK = 2
		COST_COMMENT = 3
	end

	module_function
	def self.helper_build_comment(id_type)
		binding.of_caller(1).eval("self").class_eval do
#			define_method :build_comment, ->(user) {
#				Comment.new(user_id: user.id, id_type: id_type, target_id: self.id )
#			}
			define_method :build_marked_comment do |user|
				Comment.new(user_id: user.id, id_type: id_type, target_id: self.id )
			end
		end
	end
end
