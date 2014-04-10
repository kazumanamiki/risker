class AddIndexToCommentsIdTypeTargetId < ActiveRecord::Migration
  def change
  	add_index :comments, [:id_type, :target_id]
  end
end
