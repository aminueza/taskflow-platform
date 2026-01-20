class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.references :user, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :status, default: 'pending', null: false

      t.timestamps
    end

    add_index :tasks, :status
  end
end
