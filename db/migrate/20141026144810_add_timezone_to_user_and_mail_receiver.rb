class AddTimezoneToUserAndMailReceiver < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        add_column :users         , :timezone, :string
        add_column :mail_receivers, :timezone, :string
        User.find_each do |user|
          user.timezone = ActiveSupport::TimeZone.new('Beijing').tzinfo.name
          user.save! validate: false
          user.mail_receivers.each do |mail_receiver|
            mail_receiver.save! validate: false
          end
        end
        change_column :users         , :timezone, :string, null: false
        change_column :mail_receivers, :timezone, :string, null: false
      end

      dir.down do
        remove_column :users         , :timezone, :string
        remove_column :mail_receivers, :timezone, :string
      end
    end
  end
end
