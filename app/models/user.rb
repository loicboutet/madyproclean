class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Attribute type declarations
  attribute :role, :string

  # Enums
  enum :role, { agent: 'agent', manager: 'manager', admin: 'admin' }, default: 'agent'

  # Associations
  belongs_to :manager, class_name: 'User', optional: true
  has_many :managed_users, class_name: 'User', foreign_key: 'manager_id'
  has_many :time_entries, dependent: :destroy
  has_many :schedules, dependent: :destroy
  has_many :created_schedules, class_name: 'Schedule', foreign_key: 'created_by_id', dependent: :nullify
  has_many :replacement_schedules, class_name: 'Schedule', foreign_key: 'replaced_by_id', dependent: :nullify
  has_many :absences, dependent: :destroy
  has_many :created_absences, class_name: 'Absence', foreign_key: 'created_by_id', dependent: :nullify

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :role, presence: true
  validates :employee_number, uniqueness: true, allow_nil: true
  validate :manager_must_be_manager_role

  # Scopes
  scope :active, -> { where(active: true) }
  scope :agents, -> { where(role: 'agent') }
  scope :managers, -> { where(role: 'manager') }
  scope :admins, -> { where(role: 'admin') }

  # Methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def can_manage?(user)
    admin? || (manager? && managed_users.include?(user))
  end

  private

  def manager_must_be_manager_role
    if manager.present? && !manager.manager?
      errors.add(:manager, 'must have manager role')
    end
  end
end
