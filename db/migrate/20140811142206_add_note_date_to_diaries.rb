class AddNoteDateToDiaries < ActiveRecord::Migration
  def change
    add_column :diaries, :note_date, :date, null: false
  end
end
