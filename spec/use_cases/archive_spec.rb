# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EsaArchiver::UseCases::Archive do
  let(:esa_client) { double('esa client') }
  let(:category) { 'path/to/post' }
  let(:days_ago) { '31' }
  let(:expected_date) { '2017-03-01' }
  let(:posts) do
    build_list(:esa_post, 2)
  end
  let(:expected) do
    [
      { posts[0].number => 'Archived' },
      { posts[1].number => 'Archived' }
    ]
  end

  subject { described_class.new(esa_client).call(category, days_ago) }

  before 'mock date today' do
    expect(Date).to receive(:today).and_return Date.new(2017, 4, 1)
  end

  shared_context 'mock esa api' do |post_no|
    before do
      expect(esa_client).to receive(:update_post)
        .with(
          have_attributes(number: posts[post_no].number,
                          category: 'Archived/path/to/post'), 'user1'
                        ).and_return(posts[post_no])
    end
  end

  context do
    include_context 'mock esa api', 0
    include_context 'mock esa api', 1
    it do
      expect(esa_client).to receive(:find_expired_posts)
        .with(category, expected_date).once
        .and_return(posts)
      expect(subject).to eq(expected)
    end
  end
end
