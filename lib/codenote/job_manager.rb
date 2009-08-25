module CodeNote
  class JobManager
    def self.update_slide(slide)
      return if slide.being_updated? || slide.updated?
      slide.updating!
      Job.run do
        slide.dynamic_slide_class.new(*slide.dynamic_args).update(slide)
        slide.updated!
      end
    end

    def self.register_job(job)
      @jobs ||= []
      @jobs << job
    end

    def self.kill_jobs
      puts "Killing all the jobs..."
      @jobs.each { |job| job.kill } if @jobs
    end

    class Job
      def self.run(&block)
        new(&block).run
      end

      def initialize(&block)
        @proc = block
        JobManager.register_job(self)
      end

      def run
        @pid = Kernel.fork do
          @proc.call
          Kernel.exit! # to avoid any at_exit hooks
        end
      end

      def kill
        # Kinda harsh, but TERM wasn't working.
        Process.kill(Signal.list['KILL'], @pid) if @pid
      end

    end
  end
end

at_exit do
  CodeNote::JobManager.kill_jobs
end
