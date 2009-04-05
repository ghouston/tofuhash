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
      MAJOR = 1
      MINOR = 0
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

  alias :regular_each_pair :each_pair unless method_defined?(:regular_each_pair)

  # see Hash#each
  def each &block
    self.regular_each_pair do |key, value|
      block.call( [decode(key), value] )
    end
  end

  # see Hash#each_key
  def each_key &block
    self.regular_each_pair do |key, value|
      block.call(decode(key))
    end
  end
  
  # executes the block on each key as it is stored with TofuHash (e.g. the TofuKey)
  def each_key_encoded
    self.regular_each_pair do |key, value|
      yield key
    end
  end
  
  # see Hash#each_pair
  def each_pair &block
    self.regular_each_pair do |key,value|
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
  # also aliased as include?, key?, and member?
  def has_key? key
    super( encode(key) )
  end
  alias_method 'include?', 'has_key?'
  alias_method 'key?', 'has_key?'
  alias_method 'member?', 'has_key?'
  
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

  # see Hash#default
  def default(key = nil)
    super
  end
  
  # see Hash#delete
  def delete(key, &block)
    if block_given? then
      super(encode(key)) {|e| yield e.decode }
    else
      super(encode(key))
    end
  end
  
  alias :regular_fetch :fetch
  class Missing; end # used to mark a missing argument

  # see Hash#fetch
  def fetch( key, default = Missing )
    if block_given? then
      if default == Missing then
        super(encode(key)) {|e| yield e.decode }
      else
        super(encode(key),default) {|e| yield e.decode }
      end
    else
      if default == Missing then
        super(encode(key))
      else
        super(encode(key),default)
      end
    end
  end
  
  # see Hash#index
  def index( value )
    result = super
    return decode(result) if result.is_a? TofuKey
    return result
  end
  
  # see Hash#replace
  def replace( other_hash )
    self.clear
    other_hash.each_pair do |key, value|
      self[key]=value
    end
  end
  
  # see Hash#select
  def select
    if RUBY_VERSION >= "1.9"
      result = {}
      each_pair do |key,value|
        result[key]=value if yield(key,value)
      end
      return result
    else
      result = []
      each_pair do |key,value|
        result << [key,value] if yield key,value
      end
      return result
    end
  end
  
  # see Hash#shift
  def shift
    result = super
    result[0] = decode(result[0])
    return result
  end
  
  # see Hash#sort
  # when called with a block, the keys passed to the block will be the original keys.
  def sort
    return super if RUBY_VERSION >= "1.9"
    if block_given?
      result = super {|kv1,kv2| yield( [decode(kv1[0]),kv1[1]], [decode(kv2[0]),kv2[1]] ) }
    else
      result = super
    end
    result.collect {|a| [a[0].decode, a[1]] }
  end
  
  # see Hash#==
  # comparison will use TofuKey comparison to retain the desired behavior.
  def == obj
    return false unless obj.is_a? Hash
    obj.each_pair do |key, value|
      return false unless (v = fetch( key ) {|k| Missing }).eql? value
    end
    return true
  end
  
  # see Hash#merge
  def merge( other_hash, &block )
    self.dup.merge!(other_hash, &block)
  end
  
  #see Hash#merge!
  # see Hash#update
  def merge!( other_hash )
    other_hash.each_pair do |key,value|
      if block_given? then
        if self.has_key? key then
          self[key] = yield( key, self[key], value )
        else
          self[key] = value
        end
      else
        self[key] = value
      end
    end
    self
  end
  alias_method 'update', 'merge!'
  
  #see Hash#reject
  def reject( &block )
    self.dup.delete_if(&block)
  end
  
  alias_method 'regular_reject!','reject!'
  #see Hash#reject!
  def reject!( &block )
    self.regular_reject! do |key, value|
      block.call( decode(key), value)
    end
  end
  
  #see Hash#to_hash
  def to_hash
    result = Hash.new
    self.each_pair do |key, value|
      result[key]=value
    end
    result
  end
  
  #see Hash#to_s
  def to_s
    self.to_hash.to_s
  end
  
  # see Hash#try_convert (ruby 1.9.x +)
  def TofuHash.try_convert( obj )
    h = super obj
    return nil if h.nil?
    result = TofuHash.new
    h.each_pair do |key,value|
      result[key] = value
    end
    return result
  end
end # class TofuHash
