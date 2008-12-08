=begin

TofuHash http://github.com/ghouston/tofuhash/tree/master

by Greg Houston http://ghouston.blogspot.com/

Version: 0.0.1

A varient of Hash which can change the lookup behavior of keys.  
The default TofuHash will match Symbol and String without reguard
to case.  By subclassing TofuKey, this behavior can be changed.

For example:

require 'tofuhash'
h = TofuHash[ :aSymbol => "symbol", "MixedCaseString" => "string", 11 => "number" ]
puts h["asymbol"]         #=> "symbol"
puts h[:mixedCaseString]  #=> "string"
puts h[11]                #=> "number"

Inspired by:

http://pastie.caboo.se/154304 and used with Stefan Rusterholz's permission;
and HashWithIndifferentAccess in Rail's ActiveSupport.

License:

(The MIT License + Free Software Foundation Advertising Prohibition)

Copyright (c) 2007 Gregory N. Houston

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or other
dealings in this Software without prior written authorization.

Release History:

Dec 12 2008 - 0.0.1 released on git hub.  Working solution, only more complete
testing is needed.  Know issues: a) Hash doesn't know how to compare with TofuHash.
=end

class TofuKey
  attr_reader :original_key, :coded_key

  def initialize( key )
    if key.instance_of? String
      @original_key = key.clone.freeze
    else
      @original_key = key
    end
    encode
  end

  def encode
    if @original_key.instance_of? Symbol
      @coded_key = @original_key.to_s.downcase
    elsif @original_key.respond_to? :downcase
      @coded_key = @original_key.downcase
    else
      @coded_key = @original_key
    end
  end

  def decode
    @original_key
  end

  def hash
    @coded_key.hash
  end

  def eql? obj
    if obj.instance_of? Symbol
      @coded_key.eql?( obj.to_s.downcase )
    elsif obj.instance_of? TofuKey
      @coded_key.eql?( obj.coded_key )
    elsif obj.respond_to? :downcase
      @coded_key.eql?( obj.downcase )
    else
      @coded_key.eql?( obj )
    end
  end
end

class TofuHash < Hash
  def initialize ( default = nil )
    if block_given?
      if default != nil
        raise ArgumentError, "wrong number of arguments"
      end
      super() { |h,k| yield h, decode(k) }
    else
      super
    end
  end

  def encode( key )
    TofuKey.new(key)
  end

  def decode( key )
    key.decode
  end

  class << self
    def [](*args)
      if args.size == 1 && args[0].instance_of?( Object::Hash )
        h = TofuHash.new
        args[0].each { |k,v| h.store( k,v ) }
        h
      elsif (args.size % 2 != 0)
        raise ArgumentError, "odd number of arguments for TofuHash"
      else
        h = TofuHash.new
        1.step( args.size, 2 ) { |i| h.store(args[i-1],args[i]) }
        h
      end
    end
  end

  def []= key,value
    super( encode(key), value )
  end

  alias :regular_each :each unless method_defined?(:regular_each)

  def each &block
    self.regular_each do |key, value|
      block.call( decode(key), value )
    end
  end

  def store key, value
    super( encode(key), value )
  end

  def [] key
    super( encode(key) )
  end

  def has_key? key
    super( encode(key) )
  end

  def keys
    # collect will call each which decodes the key
    self.collect { |k,v| k }
  end

  alias_method :regular_inspect, :inspect unless method_defined?(:regular_inspect)

  def values_at( *args )
    values = Array.new
    args.each { |key| values << self[key] }
    values
  end
end # class TofuHash

if __FILE__ == $0
  require 'test-tofuhash'
end