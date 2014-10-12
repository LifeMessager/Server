class RenameTableDiariesToNotes < ActiveRecord::Migration
  def change
    rename_table :diaries, :notes
  end
end
