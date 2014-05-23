class CreateLimitApis < ActiveRecord::Migration
  def change
    create_table :limit_apis do |t|
      t.string :api
      t.integer :counter
      t.datetime :counted_at

      t.timestamps
    end
    add_index :limit_apis, :api, unique: true
  end
end
