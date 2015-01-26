class AddEmailVerifiedToUser < ActiveRecord::Migration
  def up
    add_column :users, :email_verified, :boolean
    User.unscoped.find_each do |user|
      user.email_verified = true
      user.save!
    end
    change_column :users, :email_verified, :boolean, null: false, default: false
  end

  def down
    remove_column :users, :email_verified, :boolean
  end
end
