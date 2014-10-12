require 'spec_helper'

describe 'spec_helper' do
  it 'should included Requests::JSONHelpers' do
    expect(self.methods.grep(/respond_json/).length).to be > 0
  end
end
