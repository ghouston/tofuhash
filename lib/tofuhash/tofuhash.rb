# TofuHash 
#
# Links: 
# * readme.txt[link:files/readme_txt.html]
# * source: http://github.com/ghouston/tofuhash/tree/master
#
# A varient of Hash which can change the lookup behavior of keys.  
# The default TofuHash will match Symbol and String without reguard
# to case.  By subclassing TofuKey, this behavior can be changed.
# 
#
# License:
#
# (The MIT License + Free Software Foundation Advertising Prohibition)
#
# Copyright (c) 2007 Gregory N. Houston
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Except as contained in this notice, the name(s) of the above copyright holders
# shall not be used in advertising or otherwise to promote the sale, use or other
# dealings in this Software without prior written authorization.
#
class TofuHash < Hash
    module Version
      MAJOR = 0
      MINOR = 1
      REVISION = 0
      STRING = [MAJOR, MINOR, REVISION].join('.')
    end

  # see Hash.new
  def initialize ( default = nil )
    if block_given?
      if default
        raise ArgumentError, "Can't initialize Hash with both a default value and a block"
      end
      super() do |hash,key| 
        if key.is_a? TofuKey then 
          yield(hash, decode(key))
        else
          yield(hash, key)
        end
      end
    else
      super
    end
  end

  # see Hash#encode
  def encode( key )
    TofuKey.new(key)
  end

  # see Hash#decode
  def decode( key )
    key.decode
  end

  class << self
    # see Hash.[]
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

  # see Hash#[]=
  def []= key,value
    super( encode(key), value )
  end

  alias :regular_each :each unless method_defined?(:regular_each)

  # see Hash#each
  def each &block
    self.regular_each do |key, value|
      block.call( decode(key), value )
    end
  end

  # see Hash#store
  def store key, value
    super( encode(key), value )
  end

  # see Hash#[]
  def [] key
    super( encode(key) )
  end

  # see Hash#has_key?
  def has_key? key
    super( encode(key) )
  end

  # see Hash#keys
  def keys
    # collect will call each which decodes the key
    self.collect { |k,v| k }
  end

  alias_method :regular_inspect, :inspect unless method_defined?(:regular_inspect)

  # see Hash#values_at
  def values_at( *args )
    values = Array.new
    args.each { |key| values << self[key] }
    values
  end

  # see Hash#to_a
  def to_a
    aux = []
    self.each do |key,value|
      aux << [ key, value ]
    end
    aux
  end

  # see Hash#include?
  def include?(key)
    super(encode(key))
  end

  alias :regular_delete_if :delete_if

  # see Hash#delete_if
  def delete_if(&block)
    self.regular_delete_if do |key, value|
      block.call( decode(key), value)
    end
  end

  # Deletes every key-value pair for which block evaluates to false.
  def delete_unless #:yield:
    delete_if{ |key, value| ! yield(key, value) }
  end

  def default(key = nil)
    super
  end
  
  def delete(key, &block)
    if block_given? then
      super(encode(key)) {|e| yield e.decode }
    else
      super(encode(key))
    end
  end
end # class TofuHash
