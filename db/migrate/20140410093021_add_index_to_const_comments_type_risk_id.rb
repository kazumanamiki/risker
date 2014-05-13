class AddIndexToConstCommentsTypeRiskId < ActiveRecord::Migration
  def change
  	add_index :cost_comments, [:cost_type, :risk_id]
  end
end
