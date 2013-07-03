class Content < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :user
  attr_accessible :title, :file_type, :content_type, :privacy, :link, :description, :user_id, :avatar
  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  
  validates :content_type, :presence => true
  validates :title, :presence => true
  validates_format_of :link, :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix
   validates_attachment_content_type :avatar,
     :content_type => ['image/png', 'image/jpeg', 'image/jpg', 'image/gif'],  :message => "Not a valid image file (jpg, jpeg, png, gif)",
     :if => :is_type_of_image?
     
     protected
  def is_type_of_image?
    avatar.content_type =~ %r(image)
  end
end
