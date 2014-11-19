class AddLocalNoteDateToMailReceiver < ActiveRecord::Migration
  def up
    add_column :mail_receivers, :local_note_date, :date
    MailReceiver.find_each do |mail_receiver|
      mail_receiver.save!
    end
    change_column :mail_receivers, :local_note_date, :date, null: false
  end

  def down
    remove_column :mail_receivers, :local_note_date, :date
  end
end
