class AddRiskWeightToRisks < ActiveRecord::Migration
	def change
		add_column :risks, :priority, :integer
	end
end
