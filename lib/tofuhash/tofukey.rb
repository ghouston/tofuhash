# TofuKey
# 
# Links: 
# * readme.txt[link:files/readme_txt.html]
# * source: http://github.com/ghouston/tofuhash/tree/master
#
# For use with TofuHash.  A wrapper for the key of a Hash which will alter the behavior of keys.
# The behavior provided by default is case-insensitive, and indifferent access for strings and symbols.
# By subclassing TofuHash, you can create your own behavior.
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
class TofuKey
  attr_reader :original_key, :coded_key

  # preserve the key (Strings are cloned and frozen just like Hash's behavior); then encodes the key for fast comparison
  def initialize( key )
    if key.instance_of? String
      @original_key = key.clone.freeze
    else
      @original_key = key
    end
    encode
  end

  # stores a @coded_key which is used for quick comparison and as the hash key.  the default encoding will
  # convert Symbols to downcased strings; anything responding to downcase is converted via downcase.
  def encode
    if @original_key.instance_of? Symbol
      @coded_key = @original_key.to_s.downcase
    elsif @original_key.respond_to? :downcase
      @coded_key = @original_key.downcase
    else
      @coded_key = @original_key
    end
  end

  # returns the preserved key
  def decode
    @original_key
  end

  # get the hash of the key, which calls #hash on the encoded key. 
  def hash
    @coded_key.hash
  end

  # compares the encoded key to another object.  
  # 
  # given symbols are converted to downcase strings before comparison.
  # given objects which respond to downcase are downcased before comparison.
  # given TofuKey will compare the encoded keys.
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
  
  def == obj
    self.eql? obj
  end
  
  def <=> obj
    if obj.instance_of? Symbol
      @coded_key <=> obj.to_s.downcase
    elsif obj.instance_of? TofuKey
      @coded_key <=> obj.coded_key
    elsif obj.respond_to? :downcase
      @coded_key <=> obj.downcase
    else
      @coded_key <=> obj
    end
  end
end
