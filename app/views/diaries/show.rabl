object @diary
attribute :created_at, :timezone, :local_note_date

child :notes, object_root: false do
  attribute :id, :from_email, :created_at
  node(:content) { |note| clean_content note.content }
end
