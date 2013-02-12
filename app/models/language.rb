class Language < ActiveRecord::Base
  include Resourcable
  include Permissionable

  has_many :supports
  has_many :language_adjoints
  has_many :ontologies
  has_many :serializations
  has_many :language_mappings, :foreign_key => :source_id
  
  belongs_to :user

  attr_accessible :name, :iri, :description, :standardization_status, :defined_by

  validates :name, length: { minimum: 1 }

  validates :iri, length: { minimum: 1 }
  validates_uniqueness_of :iri, if: :iri_changed?
  validates_format_of :iri, with: URI::regexp(ALLOWED_URI_SCHEMAS)

  after_create :add_permission
  
  def to_s
    name
  end
  
  def add_logic(logic)
    sup = self.supports.new
    sup.logic = logic
    sup.save!
  end
  
    def mappings_from
    LanguageMapping.find_all_by_source_id self.id
  end
  
  def mappings_to
    LanguageMapping.find_all_by_target_id self.id
  end
  
private

  def add_permission
    permissions.create! :subject => self.user, :role => 'owner' if self.user
  end
end
