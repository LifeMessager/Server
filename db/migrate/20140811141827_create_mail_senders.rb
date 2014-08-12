class CreateMailSenders < ActiveRecord::Migration
  def change
    create_table :mail_senders do |t|
      t.string :address, null: false
      t.string :receiver, null: false

      t.timestamps
    end
  end
end
