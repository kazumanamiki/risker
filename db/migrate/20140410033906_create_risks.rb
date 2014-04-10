class CreateRisks < ActiveRecord::Migration
  def change
    create_table :risks do |t|
      t.string :title
      t.text :details
      t.integer :status
      t.integer :check_cycle
      t.date :watch_over_date
      t.integer :project_id

      t.timestamps
    end
  end
end
