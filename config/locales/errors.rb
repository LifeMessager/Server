
errors = {
  format: '%{message}',
  messages: {
    taken: 'already_exist',
    empty: 'missing_field',
    blank: 'invalid',
    accepted: 'invalid',
    present: 'invalid',
    confirmation: 'invalid',
    equal_to: 'invalid',
    even: 'invalid',
    exclusion: 'invalid',
    greater_than: 'invalid',
    greater_than_or_equal_to: 'invalid',
    inclusion: 'invalid',
    invalid: 'invalid',
    less_than: 'invalid',
    less_than_or_equal_to: 'invalid',
    not_a_number: 'invalid',
    not_an_integer: 'invalid',
    odd: 'invalid',
    record_invalid: 'invalid',
    restrict_dependent_destroy: {
      one: "Cannot delete record because a dependent %{record} exists",
      many: "Cannot delete record because dependent %{record} exist"
    },
    too_long: {
      one: 'invalid',
      other: 'invalid'
    },
    too_short: {
      one: 'invalid',
      other: 'invalid'
    },
    wrong_length: {
      one: 'invalid',
      other: 'invalid'
    },
    other_than: 'invalid'
  }
}

[:en, :'zh-TW', :'zh-CN'].map { |lang| [lang, errors: errors] }.to_h
