class AddLanguageToUser < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        add_column :users, :language, :string
        User.unscoped.find_each do |user|
          user.language = User.languages.first
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
