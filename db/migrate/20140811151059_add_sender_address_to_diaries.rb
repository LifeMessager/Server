class AddSenderAddressToDiaries < ActiveRecord::Migration
  def change
    add_column :diaries, :sender_address, :string, null: false
  end
end
