class AddCounterCacheToNote < ActiveRecord::Migration
  def up
    add_column :mail_receivers, :notes_count, :integer, default: 0

    MailReceiver.reset_column_information
    MailReceiver.all.each do |mail_receiver|
      mail_receiver.update_attribute :notes_count, mail_receiver.notes.count
    end
  end

  def down
    remove_column :mail_receivers, :notes_count
  end
end
