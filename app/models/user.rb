require 'digest/sha1'
class User < ActiveRecord::Base
  #set_table_name("admin_users")
  has_many :contents
  
  attr_accessible :email, :first_name, :last_name, :password, :gender, :birthday
  
  attr_accessor :password
  
  EMAIL_REGEX = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i
  
  # standard validation methods
  # validates_presence_of :first_name
  # validates_length_of :first_name, :maximum => 25
  # validates_presence_of :last_name
  # validates_length_of :last_name, :maximum => 50
  # validates_presence_of :username
  # validates_length_of :username, :within => 8..25
  # validates_uniqueness_of :username
  # validates_presence_of :email
  # validates_length_of :email, :maximum => 100
  # validates_format_of :email, :with => EMAIL_REGEX
  # validates_confirmation_of :email
  
  # new "sexy" validations
  validates :first_name, :length => { :maximum => 25 }
  validates :last_name, :length => { :maximum => 50 }
  validates :email, :presence => true, :length => { :maximum => 100 }, 
    :format => EMAIL_REGEX, :confirmation => true, :uniqueness => true
  
  #only on create, so other attributes of this user can be changed
  validates_length_of :password, :within => 8..25, :on => :create
  
  before_save :create_hashed_password, :generate_token
  after_save :clear_password
  
  scope :named, lambda {|first,last| where(:first_name=>first,:last_name=>last)}
  scope :sorted, order("users.last_name ASC, users.first_name") 
  
  def name
    "#{first_name} #{last_name}"
  end
  
  def self.authenticate(email="",password="")
    user=User.find_by_email(email)
    if user && user.password_match?(password)
      return user
    else
      return false
    end
    
  end
  
  def self.activate(token="")
    user=User.find_by_token(token)
    if user
      return user
    else
      return false
    end
  end
  
   def token_match?(token1="")
    token==token1
  end
  
  def password_match?(password="")
    hashed_password == User.hash_with_salt(password,salt)
  end
  
  def self.make_salt(email="")
    Digest::SHA1.hexdigest("Welcome #{email} to your happiness #{Time.now}")
  end
  
  def self.hash_with_salt(password="",salt="")
    Digest::SHA1.hexdigest("Put the #{salt} on your #{password}")
  end
  
  
  
  
  # def send_new_password
    # new_pass = User.random_string(10)
    # self.password = self.password_confirmation = new_pass
    # self.save
    # Notifications.deliver_forgot_password(self.email, self.login, new_pass)
  # end
# 
  # def send_activate
    # Notifications.deliver_activate(self.email, self.name, self.surname, self.id)
  # end
# 
  # def activate?
    # update_attribute('activated', true)
    # if self.activated
      # return true
    # else
      # return false
    # end
  # end
  
  
  
  
  private
  
  def generate_token
    self.token = Digest::SHA1.hexdigest([Time.now, rand].join)
  end
  
  
  def create_hashed_password
    #Whenever :password has a value, hashing is needed
    unless password.blank?
      #always use "self" when assigning values
      self.salt = User.make_salt(email) if salt.blank?
      self.hashed_password = User.hash_with_salt(password, salt) 
    end
  end
  
  def clear_password
    #for security and b/c hashing is not needed
    self.password = nil
  end
  
end
