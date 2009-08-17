require 'makers-mark'

class Slide < ActiveRecord::Base
  belongs_to :presentation
  acts_as_list :scope => :presentation, :column => :number

  def viewable_by_audience!
    update_attribute(:viewable_by_audience, true)
  end

  def html
     MakersMark::Generator.new(source).to_html
  end


end
