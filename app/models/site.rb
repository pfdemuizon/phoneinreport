class Site < ActiveRecord::Base
  cattr_accessor :current
  validates_presence_of :host
  has_many :campaigns do
    def current
      proxy_target.detect {|c| c.current?}
    end
  end
end
