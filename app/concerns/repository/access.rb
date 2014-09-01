module Repository::Access

  extend ActiveSupport::Concern

  class RemoteAccessValidator < ActiveModel::Validator
    def validate(record)
      if record.mirror? && (record.private_rw? || record.public_rw?)
        record.errors[:access] = "Error! Write access is not allowed for a mirrored repositry."
      end
    end
  end

  OPTIONS = %w[public_r public_rw private_r private_rw]
  DEFAULT_OPTION = OPTIONS[0]

  included do
    scope :pub, ->() { where("access NOT LIKE 'private%'") }

    validates_with RemoteAccessValidator
    validates :access,
      presence: true,
      inclusion: { in: Repository::Access::OPTIONS }

    def self.accessible_by(user)
      if user
        where("access NOT LIKE 'private%'
          OR id IN (SELECT item_id FROM permissions WHERE item_type = 'Repository' AND subject_type = 'User' AND subject_id = ?)
          OR id IN (SELECT item_id FROM permissions INNER JOIN team_users ON team_users.team_id = permissions.subject_id AND team_users.user_id = ?
            WHERE  item_type = 'Repository' AND subject_type = 'Team')", user, user)
      else
        pub
      end
    end

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
    if access_changed? && (access_was == 'private_r' || access_was == 'private_rw')
      permissions.where(role: 'reader').destroy_all
    end
  end

end
