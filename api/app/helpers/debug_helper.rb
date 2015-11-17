module DebugHelper

  VERBOSE = {
    console: true,
    logger: true
  }

  def self.resque_logger(msg)
    if VERBOSE[:logger]
      Resque.logger.info('')
      Resque.logger.info(msg)
    end
  end

  def self.console(msg)
    if VERBOSE[:console]
      puts
      puts msg
    end
  end

  def self.output_debug_info(error_msg, header)
    resque_logger header
    console header

    resque_logger error_msg
    console error_msg
  end

  def self.output_data(data)
    resque_logger data
    console data
  end
end