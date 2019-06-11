require_relative 'support/http_response_stub.rb'
require_relative 'support/reset_rspec.rb'
include HttpResponseStub
include ResetRspec

RSpec.describe Gig do
  let(:directory_name) { "topic:ruby-topic:rails" }

  it "has a version number" do
    expect(Gig::VERSION).not_to be nil
  end

  it "return download info message, after downloads an avatar images" do
    # TODO: Stub images download; Test pagination;

    allow_any_instance_of(Gig::Greper).to receive(:get_http_response).and_return(Response)
    allow(STDIN).to receive(:gets) { 'no' }

    expect{ Gig.call(["topic:ruby", "topic:rails"]) }.to output(a_string_including("Downloaded 2 images.")).to_stdout
    expect(Dir).to exist(directory_name)
    expect(Dir["#{directory_name}/*"].length).to be 2

    StorageCleaner.clear_directory(directory_name)
  end
end
