require "open3"
include Open3

module Calc
  
  @bufferedStatement = ''
  @scopeDepth = 0
  
  def Calc::process
    @stdin, @stdout, @stderr = Open3.popen3('bc -l 2>&1')
    
    ARGF.each_with_index do |line, index|
      # find statements in line
      if line[0] == "\t" || line[0..3] == "    "
        # if line starts with a single tab it is expected to all be a statemet
        # one line can contain multiple statements separated by ;
        puts processLine(line)
      else
        # Check line for embedded statements
        line = line.gsub(/`.*?`/) {|statement|
          statement.gsub!('`', '')
          statement = processLine(statement)
          '`'+statement+'`'
        }
        puts line
      end
    end
      
    @stdin.close
    @stderr.close
    @stdout.close
  end
  
  def Calc::processLine(line)
    line.split(";").map{|statement| 
      # Allow statements to span lines if a line ends with a operator
      @bufferedStatement += ' ' + statement.strip()
      if statement.strip().match(/[+-\/*^]$/)
        return statement
      end
      
      beginCount = statement.scan("{").count;
      if beginCount > 0
        @scopeDepth += beginCount
      end

      endCount = statement.scan("}").count;
      if endCount > 0
        @scopeDepth -= endCount
        if @scopeDepth < 0
          @scopeDepth = 0
        end
      end
      if(@scopeDepth > 0) 
        @bufferedStatement = @bufferedStatement.strip().gsub(/!?\=>.*$/, '') + ";"
        return statement
      end
      
      preprocessedStatement = preprocessStatement(@bufferedStatement)
      @bufferedStatement = ''
      if(preprocessedStatement == "")
        return statement
      end
      # puts "PROCESS "+preprocessedStatement
      @stdin.puts preprocessedStatement
      @stdin.puts "\"xENDCOMMAND\n\""
      @stdin.flush
      # Get last line of error and result
      result = ""
      while (input = @stdout.gets) != "xENDCOMMAND\n"
        result = input
        # puts "RESULT "+result
      end
      result.strip!

      if result.scan(":").count > 0
        if(statement.scan("=>").count > 0) 
          return statement.gsub /\=>.*$/, '=> ' + formatResult(result)
        else
          return statement.chomp + ' !=> ' + formatResult(result)
        end 
      else 
        if(statement.scan("!=>").count > 0) 
          return statement.gsub /!\=>.*$/, ''
        else
          return statement.gsub /\=>.*$/, '=> ' + formatResult(result)
        end
      end
    }.join(";")
  end
  
  def Calc::formatResult(result)
    if result.count(":") > 0
      result = result.split(":")
      result = "Error: "+result[1].strip
    else
      result = humanNumber(result.to_f)
    end
    result
  end
  
  
  def Calc::preprocessStatement(input)
    result = input.strip().gsub(/!?\=>.*$/, '')\
         .gsub("\"", "")\
         .gsub("x", "xx")\
         .downcase\
         .gsub(/,([0-9]{3})/, '\1')\
         .inspect.gsub(/^"/, "").gsub(/"$/, "")\
         .gsub("\\", "x")\
         .gsub(/([0-9])%/, '\1/100')

     while result.match /([a-zA-Z][a-zA-Z0-9]*)( +?)([a-zA-Z])/ do
       result.gsub!(/([a-zA-Z][a-zA-Z0-9]*)( +?)([a-zA-Z])/, '\1_\3')
     end
     result.gsub!(/define_([a-zA-Z_][a-zA-Z0-9_]*) *\(/, 'define \1 (')
     result.gsub!(/return_([a-zA-Z0-9_]+)/, 'return \1')

     if result.count("=") > 0 
       result = "(" + result + ")"
     end
     result
  end
  
  def Calc::humanNumber(input)
    output = ((input * 10000).round/10000.0).to_s.split(".")
    while output[0].sub!(/(\d+)(\d\d\d)/,'\1,\2'); end
    output[0]+"."+output[1]
  end

end

