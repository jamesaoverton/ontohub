module Ontology::Versions
  extend ActiveSupport::Concern

  included do
    belongs_to :ontology_version

    has_many :versions,
      :dependent  => :destroy,
      :order      => :number,
      :autosave   => false,
      :class_name => 'OntologyVersion' do
        def current
          reorder('number DESC').first
        end
      end

    attr_accessible :versions_attributes
    accepts_nested_attributes_for :versions

    def update_version!(to: nil)
      if to
        self.ontology_version_id = to.id
      else
        self.ontology_version_id = versions.current.id
      end
      save!
    end

    def current_version
      if self.ontology_version
        self.ontology_version
      else
        self.versions.current
      end
    end

    def active_version
      return current_version if self.state == 'done'
      OntologyVersion.
        where(ontology_id: self, state: 'done').
        order('number DESC').
        first
    end

    # Answer the question if there is an active version
    # which is actually not the most current one.
    # However the question is only answered
    # truthfully if the user is either an admin
    # or the creator of the particular current version.
    def non_current_active_version?(user=nil)
      real_process_state = active_version != current_version
      if user && (user.admin || current_version.try(:user) == user)
        real_process_state
      else
        false
      end
    end

    def self.with_active_version
      state = "done"
      includes(:versions).
      where(id: OntologyVersion.where(state: state).select(:ontology_id))
    end

    def self.in_process(user=nil)
      return [] if user.nil?
      state = "done"
      stmt = ['state != ?', state] if user == true
      if user.is_a?(User)
        stmt = ['state != ? AND ' +
          'ontologies.id IN (SELECT ontology_id FROM ontology_versions ' +
          'WHERE user_id = ?)', state, user.id]
      end
      includes(:versions).
      where(stmt)
    end

  end

  # Updates the ontology and returns the new version
  def save_file(file, message, user)
    repository.save_file(file, path, message, user)
  end

end
