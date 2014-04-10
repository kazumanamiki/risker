class CreateCostComments < ActiveRecord::Migration
  def change
    create_table :cost_comments do |t|
      t.integer :type
      t.text :comment
      t.text :cost_memo
      t.integer :risk_id

      t.timestamps
    end
  end
end
