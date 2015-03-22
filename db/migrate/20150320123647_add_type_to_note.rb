class AddTypeToNote < ActiveRecord::Migration
  def change
    add_column :notes, :type, :string
    Note.find_each do |note|
      note.update_attribute :type, 'TextNote'
    end
  end
end
