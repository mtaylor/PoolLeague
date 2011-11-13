class User < ActiveRecord::Base
  before_create :create_notification
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :firstname, :lastname, :username, :rating

  def full_name
    firstname + " " + lastname
  end

  def full_nick_name
    firstname + lastname + " (" + username + ")"
  end

  def pool_name
    firstname + " \"" + username + "\" " + lastname
  end

  def create_notification
    n = Notification.new(:message => full_name + " has just signed up to RedHat Pool.");
    n.save! 
  end
end
