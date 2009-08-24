module CodeNote
  class JobManager
    def self.update_slide(slide)
      Kernel.fork do
        slide.dynamic_slide_class.new(*slide.dynamic_args).update(slide)
        Kernel.exit! # to avoid any at_exit hooks
      end
    end
  end
end
