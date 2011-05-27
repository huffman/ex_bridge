module Runner
  def start([])
    process ["test"]
  end

  def start(other)
    process other
  end

  def process ["compile"|t]
    compile!
    process t
  end

  def process ["setup"|t]
    execute "git submodule update --init"
    execute "cd deps/mochiweb && make"
    execute "cd deps/ibrowse && make"
    execute "cd deps/misultin && make"
    process t
  end

  def process ["test"|t]
    compile!
    execute "time exunit -pa exbin test/ex_bridge/*/*_test.exs"
    execute "time exunit -pa exbin test/frankie/*_test.exs"
    process t
  end

  def process [other|t]
    IO.new('standard_error).puts "Unknown command: #{other}"
    self.exit(1)
    process t
  end

  def process []
    % Done
  end

  private

  def compile!
    execute "elixirc -s elixirc.spec -o exbin"
  end

  def execute command
    IO.puts command
    result = OS.cmd command
    IO.puts result
  end
end

Runner.start(Code.argv)