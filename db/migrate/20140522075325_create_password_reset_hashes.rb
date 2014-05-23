class CreatePasswordResetHashes < ActiveRecord::Migration
  def change
    create_table :password_reset_hashes do |t|
      t.integer :user_id
      t.string :hash_pass
      t.boolean :enable_flag

      t.timestamps
    end
    add_index :password_reset_hashes, :user_id, unique: true
    add_index :password_reset_hashes, :hash_pass
  end
end
