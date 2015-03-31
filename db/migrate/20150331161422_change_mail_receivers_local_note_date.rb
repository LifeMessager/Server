class ChangeMailReceiversLocalNoteDate < ActiveRecord::Migration
  def change
    rename_column :mail_receivers, :local_note_date, :locale_date
  end
end
