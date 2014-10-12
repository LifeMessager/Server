class AddUserRefToMailReceivers < ActiveRecord::Migration
  def change
    add_reference :mail_receivers, :user, index: true, null: false
    remove_column :mail_receivers, :receiver, :string
  end
end
