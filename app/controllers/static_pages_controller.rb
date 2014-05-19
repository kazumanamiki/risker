class StaticPagesController < ApplicationController
	def root
		if signed_in?
			redirect_to user_path(current_user)
		end
	end

	def history
	end
end
