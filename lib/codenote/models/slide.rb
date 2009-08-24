require 'makers-mark'

class Slide < ActiveRecord::Base
  belongs_to :presentation
  acts_as_list :scope => :presentation, :column => :number
  serialize :dynamic_args, Array
  before_create :define_initial_slide_source_for_dynamic_slides

  def viewable_by_audience!
    update_attribute(:viewable_by_audience, true)
  end

  def dynamic_options=(options_string)
    return unless options_string =~ /^\s*([^\s]+)\s*(.*)$/
    self.dynamic_slide_class = $1
    self.dynamic_args = eval("[#{$2}]")
  end


  def dynamic_slide_class
    @dynamic_slide_class ||= (
      begin
        self['dynamic_slide_class'].constantize
      rescue
        require "codenote/dynamic_slides/#{self['dynamic_slide_class'].underscore}"
        retry
      end
    )
  end

  def html
     MakersMark::Generator.new(source).to_html
  end

  def dynamic?
    !self['dynamic_slide_class'].blank?
  end

  private


  def define_initial_slide_source_for_dynamic_slides
    return if !dynamic? || !source.blank?
    self.source = File.read(CodeNote.home_path_to('views', 'dynamic_slides', self['dynamic_slide_class'].underscore, 'initial_content.md'))
  end


end
