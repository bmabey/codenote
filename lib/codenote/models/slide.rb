require 'makers-mark'

class Slide < ActiveRecord::Base
  belongs_to :presentation
  acts_as_list :scope => :presentation, :column => :number

  def image
    viewable_by_audience? ? self['image'] : "no_peeking.png"
  end

  def viewable_by_audience!
    self.update_attribute(:viewable_by_audience, true)
  end

  def html
     MakersMark::Generator.new(source).to_html
  end


end
