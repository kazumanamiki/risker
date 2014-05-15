class AddNextCheckDateToRisks < ActiveRecord::Migration
	def change
		add_column :risks, :next_check_date, :datetime
		add_index :risks, [:project_id, :next_check_date]
	end
end
