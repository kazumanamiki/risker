class StaticPagesController < ApplicationController
	def root
		if signed_in?
			redirect_to user_path(current_user)
		end
	end

	def history
	end

	def counter
		@user_count = User.count
		@project_count = Project.count
		@risk_count = Risk.count
		@cost_comment_count = CostComment.count

		d = DateTime.current
		@last_update = d.change(min: (d.minute / 40)*40)
	end
end
