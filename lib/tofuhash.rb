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
unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
  $:.unshift(File.expand_path(File.dirname(__FILE__)))
end

require 'tofuhash/tofukey'
require 'tofuhash/tofuhash'
