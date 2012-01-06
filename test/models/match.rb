class Match
  include Mongoid::Document
  include Mongoid::CachedFields

  belongs_to :referee, :inverse_of => :matches #, :cache => :name

  has_many :players, :inverse_of => :matches #, :cache => [:name, :full_name]



  # Manual cache

  class CachedReferee < Mongoid::CachedDocument
    self.cached_fields = ['name']
    self.cache_from = :referee
  end

  embeds_one :cached_referee, :class_name => 'Match::CachedReferee'
  # alias_method :referee, :cached_referee

  # TODO: test proxy delegation
  alias_method :source_referee, :referee
  def referee
    @cached_document_proxy ||= Mongoid::CachedDocumentProxy.new(_parent, source_referee, cached_referee)
  end

  before_save :update_cached_referee

  def update_cached_referee

    if referee.present?
      build_cached_referee unless cached_referee.present?
      cached_referee.update_cache
    else
      self.cached_referee = nil
    end
  end

end