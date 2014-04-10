class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :user_id
      t.text :comment
      t.integer :id_type
      t.integer :target_id

      t.timestamps
    end
  end
end
