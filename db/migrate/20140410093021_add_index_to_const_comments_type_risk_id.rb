class AddIndexToConstCommentsTypeRiskId < ActiveRecord::Migration
  def change
  	add_index :cost_comments, [:type, :risk_id]
  end
end
