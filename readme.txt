= TofuHash
  by Gregory N. Houston
  
TofuHash makes it possible to use a Hash without having to
worry about the differences between using String, Symbol,
uppercase and downcase for the keys.
TofuHash is both a case-insensitive Hash, and indifferent
to access by String or Symbol.

for Example:

 require 'tofuhash'
 h = TofuHash[ :aSymbol => "symbol", "MixedCaseString" => "string", 11 => "number" ]
 puts h["asymbol"]         #=> "symbol"
 puts h[:mixedCaseString]  #=> "string"
 puts h[11]                #=> "number"

Version:: 1.0.0 A well tested, complete version which support all Hash methods.

Tested to work with:
Ruby 1.8.6
Ruby 1.9.1

How is TofuHash different than Hash?
* TofuHash wraps the key into a TofuKey which is used internally inside TofuHash.
  The TofuKey defines new behavior for handling the key.  By
  default it will treat Symbol, String, and uppercase vs downcase as the same. This
  behavior can be changed by creating TofuHash and providing an alternative
  version of TofuKey.

* TofuHash adds the method TofuHash#delete_unless

* TofuHash.compare_by_identity (ruby 1.9 or later) is useless because TofuHash encodes the key into a TofyKey,
therefore when compare_by_identity is used TofuHash will never match the given key.  This matches
the behavior of Hash with strings for keys.  The string is cloned, so compare_by_identity is also
useless for that situation.

== Links:

Start Here:: http://tofuhash.rubyforge.org

Project:: http://rubyforge.org/projects/tofuhash
Documents:: http://tofuhash.rubyforge.org
RubyGems:: Install with: <b>gem install tofuhash</b>
Download:: Download from RubyForge at http://rubyforge.org/projects/tofuhash/
Authors Blog::   http://ghouston.blogspot.com
Browse Source:: link:rcov/index.html
Source code is hosted on Github at: http://github.com/ghouston/tofuhash/tree/master

== LICENSE:

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

The file test-tofuhash.rb is released under the Ruby License since it
contains source code based on Ruby's released source.

== Credits:

Inspired by:
* http://pastie.caboo.se/154304 and used with Stefan Rusterholz's permission;
* HashWithIndifferentAccess in Rail's ActiveSupport.

Contributors:
* Greg Houston (http://ghouston.blogspot.com) original release and project maintainer
* Nacho Caballero (http://github.com/nachocab/)  added #to_a, #delete_if, #delete_unless, #include?

== Release History:

April 4 2009 - 1.0.0 release on rubyforge and git hub.  Completed testing the entire Hash interface!
Added all missing or misbehaving methods from Hash.  Tested against both ruby 1.8.6 and 1.9.1.

Feb 28 2009 - 0.1.0 release on rubyforge.  Added gem, rdoc, rcov output.
Added TofuHash::Version module

Feb 15 2009 - 0.0.2 released on git hub.  Merged in pull request from 
http://github.com/nachocab/tofuhash/tree/master [Thanks nachocab!]
nachocab added to_a, delete_if, delete_unless, include? methods.  nachocab also
updated the exception raised when TofuHash#initialize is called with both
a default value and default block.  It now raises "wrong number of arguments"
which matches the behavior of Hash. I (ghouston) tweaked the test cases to match
the examples from Hash's ri documentation.

Dec 12 2008 - 0.0.1 released on git hub.  Working solution, only more complete
testing is needed.  Know issues: a) Hash doesn't know how to compare with TofuHash.
