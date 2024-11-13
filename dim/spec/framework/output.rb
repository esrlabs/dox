require 'stringio'

class ThreadOut < IO
  def initialize(out, sym)
    @out = out
    @sym = sym
  end

  def out(stuff, method)
    if Thread.current[@sym]
      Thread.current[@sym].send(method, stuff)
    else
      @out.send(method, stuff)
    end
  end

  def write(stuff = '')
    out(stuff, __method__)
  end

  def puts(stuff = '')
    out(stuff, __method__)
  end

  def flush
    if Thread.current[@sym]
      Thread.current[@sym].flush
    else
      begin
        @out.flush
      rescue Exception
        self
      end
    end
  end
end

$stdout.sync = true
$stderr.sync = true
$stdout = ThreadOut.new($stdout, :stdout)
$stderr = ThreadOut.new($stderr, :stderr)
