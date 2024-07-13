require 'rails_helper'

RSpec.describe PostToXJob, type: :job do
  let(:service) { instance_double(PostToXService) }

  before do
    allow(PostToXService).to receive(:new).and_return(service)
    allow(service).to receive(:call)
  end

  it 'calls PostToXService' do
    expect(service).to receive(:call)
    PostToXJob.perform_now
  end
end
