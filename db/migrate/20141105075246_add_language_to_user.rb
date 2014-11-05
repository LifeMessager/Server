class AddLanguageToUser < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        add_column :users, :language, :string
        User.find_each do |user|
          user.language = 'zh-Hans'
          user.save! validate: false
        end
        change_column :users, :language, :string, null: false
      end

      dir.down do
        remove_column :users, :language, :string
      end
    end
  end
end
