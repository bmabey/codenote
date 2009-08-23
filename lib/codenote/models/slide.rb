require 'makers-mark'

class Slide < ActiveRecord::Base
  belongs_to :presentation
  acts_as_list :scope => :presentation, :column => :number
  serialize :dynamic_args, Array

  def viewable_by_audience!
    update_attribute(:viewable_by_audience, true)
  end

  def dynamic_options=(options_string)
    return unless options_string =~ /^\s*([^\s]+)\s*(.*)$/
    self.dynamic_slide_class = $1
    self.dynamic_args = eval("[#{$2}]")
  end


  def dynamic_slide_class
    self['dynamic_slide_class'].constantize
  end

  def html
     MakersMark::Generator.new(source).to_html
  end


end
