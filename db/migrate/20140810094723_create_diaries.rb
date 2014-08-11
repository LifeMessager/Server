class CreateDiaries < ActiveRecord::Migration
  def change
    create_table :diaries do |t|
      t.string :from_email, null: false
      t.text :content, null: false
      t.references :user, null: false

      t.timestamps
    end
  end
end
