class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :user_streaming_services, dependent: :destroy
  has_many :streaming_services, through: :user_streaming_services
  has_many :movie_watchlists
  belongs_to :country
end
