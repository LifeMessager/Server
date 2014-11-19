object @diary
attribute :created_at, :timezone, :local_note_date

child :notes, object_root: false do
  attribute :id, :from_email, :content, :created_at
end
