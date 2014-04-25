module Repository::Access

  extend ActiveSupport::Concern

  OPTIONS = %w[public_r public_rw private_r private_rw]
  DEFAULT_OPTION = OPTIONS[0]

  included do
    scope :pub, where("access != 'private'")
    scope :accessible_by, ->(user) do
      if user
        where("access NOT LIKE 'private%'
          OR id IN (SELECT item_id FROM permissions WHERE item_type = 'Repository' AND subject_type = 'User' AND subject_id = ?)
          OR id IN (SELECT item_id FROM permissions INNER JOIN team_users ON team_users.team_id = permissions.subject_id AND team_users.user_id = ?
            WHERE  item_type = 'Repository' AND subject_type = 'Team')", user, user)
      else
        pub
      end
    end

    validates :access,
      presence: true,
      inclusion: { in: Repository::Access::OPTIONS }
  end

  def is_private
    access.start_with?('private')
  end

  def private_r?
    access == 'private_r'
  end

  def private_rw?
    access == 'private_rw'
  end

  def public_rw?
    access == 'public_rw'
  end

  def public_r?
    access == 'public_r'
  end

  def self.as_read_only(access)
    access.split('_').first + '_r'
  end
  
  private

  def clear_readers
    if access_changed? and access_was == 'private'
      permissions.where(role: 'reader').destroy_all
    end
  end

end
