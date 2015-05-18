class AddForeignKeys < ActiveRecord::Migration
  def change
    add_foreign_key :mail_receivers, :users
    add_foreign_key :notes, :mail_receivers
  end
end
