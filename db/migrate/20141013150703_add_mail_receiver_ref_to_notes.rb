class AddMailReceiverRefToNotes < ActiveRecord::Migration
  def change
    add_reference :notes, :mail_receiver, index: true, null: false
    remove_column :notes, :note_date, :date
    remove_column :notes, :sender_address, :string
    remove_reference :notes, :user, index: true, null: false
  end
end
