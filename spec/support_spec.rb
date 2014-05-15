require 'spec_helper'

describe 'spec_helper' do
  it 'should included Requests::JSONHelpers' do
    self.methods.grep(/respond_json/).length.should be > 0
  end
end
