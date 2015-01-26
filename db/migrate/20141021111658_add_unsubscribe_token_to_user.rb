class AddUnsubscribeTokenToUser < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        add_column :users, :unsubscribe_token, :string
        User.unscoped.find_each do |user|
          user.instance_eval { generate_unsubscribe_token }
          user.save!
        end
        change_column :users, :unsubscribe_token, :string, null: false
      end

      dir.down do
        remove_column :users, :unsubscribe_token, :string
      end
    end
  end
end
