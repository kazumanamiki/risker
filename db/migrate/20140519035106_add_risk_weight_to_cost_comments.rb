class AddRiskWeightToCostComments < ActiveRecord::Migration
	def change
		add_column :cost_comments, :probability, :integer
		add_column :cost_comments, :influence, :integer
		add_column :cost_comments, :priority, :integer
	end
end
