require 'makers-mark'
require 'codenote/job_manager'

module CodeNote

  class Slide < ActiveRecord::Base
    belongs_to :presentation
    acts_as_list :scope => :presentation, :column => :number
    serialize :dynamic_args, Array
    before_create :define_initial_slide_source_for_dynamic_slides

    acts_as_state_machine :initial => :not_updated, :column => 'status'
    state :not_updated
    state :being_updated
    state :updated
    event(:updating) { transitions :to => :being_updated, :from => :not_updated }
    event(:updated)  { transitions :to => :updated, :from => :being_updated }

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
          CodeNote.const_get(self['dynamic_slide_class'])
        rescue
          require "codenote/dynamic_slides/#{self['dynamic_slide_class'].underscore}"
          retry
        end
      )
    end

    def html
      return self['html'] unless self['html'].blank?
      CodeNote::JobManager.update_slide(self) if dynamic?
      self.html = MakersMark::Generator.new(source).to_html
      self.save!
      self.html
    end

    # TODO: Move this render and view finding logic out of Slide- SRP anyone?
    def update_with(render_options)
      render_options[:template] ||= 'success'
      template = dynamic_slide_view("update_#{render_options[:template]}.haml")
      File.open(update_slide_path, 'w') do |update|
        update << Haml::Engine.new(template).render(Object.new, render_options[:locals])
      end
    end

    def dynamic?
      !self['dynamic_slide_class'].blank?
    end

    private

    def define_initial_slide_source_for_dynamic_slides
      return if !dynamic? || !source.blank?
      self.source = dynamic_slide_view('initial_content.md')
    end

    def dynamic_slide_view(view_name)
      File.read(CodeNote.home_path_to('views', 'dynamic_slides', self['dynamic_slide_class'].underscore, view_name))
    end

    def update_slide_path
      base_path = CodeNote.home_path_to('public', 'slides', id.to_s)
      FileUtils.mkdir_p(base_path) unless File.exist?(base_path)
      base_path + '/update'
    end

  end

end
