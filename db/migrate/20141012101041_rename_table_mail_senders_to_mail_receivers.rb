class RenameTableMailSendersToMailReceivers < ActiveRecord::Migration
  def change
    rename_table :mail_senders, :mail_receivers
  end
end
