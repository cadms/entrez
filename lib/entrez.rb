require 'httparty'
require 'query_string_normalizer'
require 'entrez/query_limit'

module Entrez

  include HTTParty
  base_uri 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils'
  default_params tool: 'ruby', email: (ENV['ENTREZ_EMAIL'] || raise('please set ENTREZ_EMAIL environment variable'))
  query_string_normalizer QueryStringNormalizer

  extend QueryLimit

  class << self

    # E.g. Entrez.EFetch('snp', id: 123, retmode: :xml)
    def EFetch(db, params = {})
      perform '/efetch.fcgi', db, params
    end

    # E.g. Entrez.EInfo('gene', retmode: :xml)
    def EInfo(db, params = {})
      perform '/einfo.fcgi', db, params
    end

    # E.g. Entrez.ESearch('genomeprj', {WORD: 'hapmap', SEQS: 'inprogress'}, retmode: :xml)
    # search_terms can also be string literal.
    def ESearch(db, search_terms = {}, params = {})
      params[:term] = search_terms.is_a?(Hash) ? convert_search_term_hash(search_terms) : search_terms
      response = perform '/esearch.fcgi', db, params
      parse_ids_and_extend response
      response
    end

    # E.g. Entrez.ESummary('snp', id: 123, retmode: :xml)
    def ESummary(db, params = {})
      perform '/esummary.fcgi', db, params
    end

    def perform(utility_path, db, params = {})
      respect_query_limit unless ignore_query_limit?
      if params[:id] && Array(params[:id]).length > 100
        post utility_path, :body => {db: db}.merge(params)
      else
        get utility_path, :query => {db: db}.merge(params)
      end
    end

    # Take a ruby hash and convert it to an ENTREZ search term.
    # E.g. convert_search_term_hash {WORD: 'low coverage', SEQS: 'inprogress'}
    # #=> 'low coverage[WORD]+AND+inprogress[SEQS]'
    def convert_search_term_hash(hash, operator = 'AND')
      raise UnknownOperator.new(operator) unless ['AND', 'OR'].include?(operator)
      str = hash.map do |field, value|
        value = value.join(',') if value.is_a?(Array)
        "#{value}[#{field}]"
      end.join("+#{operator}+")
      if operator == 'OR'
        str = "(#{str})"
      end
      str
    end

    def proxy(addr, port, user=nil, pass=nil)
      http_proxy addr, port, user, pass
    end

    def parse_ids_and_extend(response)
      response.instance_eval do
        def ids
          if parse_ids?
            return @ids if @ids
            id_list = parsed_response['eSearchResult']['IdList']
            if id_list && id_list['Id']
              id_content = id_list['Id']
              id_content = [id_content].flatten
              @ids = id_content.map(&:to_i)
            else
              @ids = []
            end
          end
        end

        # Parse only if this is an ESearch request and in xml format.
        def parse_ids?
          (request.path.to_s.match /esearch/) && (request.options[:query][:retmode].nil? || retmode == :xml)
        end
      end
    end
  end

  class UnknownOperator < StandardError
    def initialize(operator)
      super "Unknown operator: #{operator}"
    end
  end

end
