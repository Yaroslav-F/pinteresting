class Pin < ActiveRecord::Base
  belongs_to :user
  has_attached_file :image, :styles => { :medium => "300x300>", :thumb => "100x100>" }
	validates_attachment_content_type :image, :content_type => ["image/jpg", "image/jpeg", "image/png"]
	validates :description, presence: true
	validates :image, presence: true
  validates_presence_of :user_id

  geocoded_by :address
  after_validation :geocode
  after_create :set_zip
  after_create :notify_nearby_owners

  markable_as :offer, :request

  def self.search(address)
    near(address)
  end

  def gmaps_infowindow
    "<a href='/pins/#{id}'><img src=\"#{image.url}\" width= '200' height='200'></a><br> 
    #{description}<br>
    <strong>#{user.name}</strong>"
  end

  def offer?
    marked_as? :offer
  end

  def request?
    marked_as? :request
  end

  def set_zip
    update_attributes(zip: Geocoder.search("#{latitude}, #{longitude}").first.try(:postal_code))
  end

  def address
    user.address
  end

  def is_near? user
    Pin.near(user.address, 1).include? self
  end

  def notify_nearby_owners
    NearbyMailer.pin_notify(self).deliver
  end
end

