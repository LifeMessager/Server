object @diary
attribute :created_at, :timezone, :locale_date

child :notes, object_root: false do
  attribute :id, :from_email, :created_at
  node(:type) { |note| note.type.downcase.gsub(/note$/, '') }
  node(:content) { |note| clean_content note }
end
