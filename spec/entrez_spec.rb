require 'spec_helper'

describe Entrez do

  it 'should have default params for tool and email' do
    Entrez.default_params[:tool].should eq('ruby')
    Entrez.default_params[:email].should_not be_nil
  end

  it '#EFetch retrieves results' do
    response = Entrez.EFetch('taxonomy', id: 9606, retmode: :xml)
    response.body.should include('Homo sapiens')
  end

  it '#ESummary retrieves results' do
    response = Entrez.ESummary('genomeprj', id: 28911)
    response.body.should include('Hapmap')
  end

  it '#EInfo retrieves results' do
    response = Entrez.EInfo('snp', retmode: :xml)
    response.body.should include('<Name>RS</Name>')
  end

  context '#ESearch' do

    it 'retrieves results' do
      response = Entrez.ESearch('genomeprj', {WORD: 'hapmap', SEQS: 'inprogress'}, retmode: :xml)
      response.body.should include('28911')
    end

    it 'response returns IDs for convenience' do
      response = Entrez.ESearch('genomeprj', {WORD: 'hapmap', SEQS: 'inprogress'}, retmode: :xml)
      response.ids.should == [60153, 29429, 28911, 48101, 59851, 59849, 59847, 59845, 59839, 59835, 59833, 59831, 51895, 59829, 59827, 60835, 59811, 60831, 60819, 33895]
    end

    it 'returns empty array if nothing found' do
      response = Entrez.ESearch('genomeprj', {NON_EXISTENT_SEARCH_FIELD: 'does not exist even in oompaloompa land'}, retmode: :xml)
      response.ids.should be_empty
    end

    it 'returns array even if only 1 id found' do
      id = 60153
      response = Entrez.ESearch('genomeprj', {uid: id}, retmode: :xml)
      response.ids.should == [id]
    end

    it 'accepts string as search_terms parameter' do
      response = Entrez.ESearch('genomeprj', 'hapmap[WORD]', retmode: :xml)
      response.ids.should include(60153)
    end

    it 'can handle array of uids' do
      response = Entrez.ESearch('gene', {UID: [1, 2, 3]})
      response.ids.should =~ [1, 2, 3]
    end

  end

  it 'should respect query limit' do
    requests = proc { 4.times { Entrez.EFetch('taxonomy', id: 9606) } }
    requests.should take_longer_than(1.0)
  end

end
