require 'tofuhash'
require 'test/unit'
require 'pp'

=begin
test-tofuhash.rb

Test cases for TofuHash.  This includes modified versions of Ruby's unit tests
for Hash, and Ruby's Hash examples in the ri documentation.  Plus some custom
tests to validate similarities between Hash and TofuHash.

Version: see tofuhash.rb for details.

License:

tofuhash.rb is released under the MIT License + Free Software Foundation
Advertising Prohibition.  see that file for details.

test-tofuhash.rb (this file) is released under the Ruby License since it
contains source code based on Ruby's released source.
=end

#
# Note, when asserting a Hash vs a TofuHash; the TofuHash must appear as the
# left argument.  This is because Hash doesn't know how to compare to a TofuHash
# in this release.
#

module TofuHashTesting
  class Test_TofuHash < Test::Unit::TestCase
    def test_new
      assert_raise ArgumentError do
        h = TofuHash.new( :default ) { |hash,key| key }
      end
      
      h = TofuHash.new
      assert_equal( 0, h.size )
      assert_equal( nil, h[:missing] )
      
      h = TofuHash.new( :default )
      assert_equal( 0, h.size )
      assert_equal( :default, h[:missing] )
      
      h = TofuHash.new do |hash,key|
        assert_equal( :missing, key )
        assert_same( h, hash )
        hash[key] = :default_block
      end
      assert_equal( 0, h.size )
      assert_equal( :default_block, h[:missing] )
      assert_equal( 1, h.size )
      assert_equal( [:missing], h.keys )
      assert_equal( [:default_block], h.values )
    end
    
    def test_values_at
      h = TofuHash[21=>22,22=>24,23=>26,24=>28]
      assert_equal([24,26], h.values_at( 22, 23 ))
    end
    
    def test_keys
      h = TofuHash["Alpha"=>2,:betA=>4,"gAmmA"=>6]
      assert_equal( ["Alpha",:betA,"gAmmA"], h.keys.sort { |a,b| a.to_s <=> b.to_s } )
    end

    def test_square_bracket_initializer
      h = TofuHash[:a=>:b, :c=>:d]
      assert_equal( TofuHash, h.class )
      assert_equal( :b, h[:a] )
      assert_equal( :d, h[:c] )
      assert_equal( 2, h.size )
      
      assert_raise ArgumentError do
        h = TofuHash[1,2,3]
      end
      
      h = TofuHash[:happy, :sad, :rich, :poor]
      assert_equal( TofuHash, h.class )
      assert_equal( :sad, h[:happy] )
      assert_equal( :poor, h[:rich] )
      assert_equal( 2, h.size )
      h = TofuHash[]
      assert_equal( 0, h.size )
    end
    
    def test_store
      h = TofuHash.new 
      h.store('Alpha',1)
      h.store(1,'ALPHA')
      assert_equal( 1, h['AlPhA'] )
      assert_equal( 'ALPHA', h[1] )
      
      h['Beta']=2
      h[2] = 'Beta'
      assert_equal( 2, h['bEtA'] )
      assert_equal( 'Beta', h[2] )
      
      h[:Gamma]=3
      h[3] = 'Gamma'
      assert_equal( 3, h[:Gamma] )
      assert_equal( 3, h['Gamma'] )
      assert_equal( 3, h['gAmMA'] )
      assert_equal( 3, h[:gAMMA] )
    end
    
    def test_each
      h = TofuHash[15,16, 11,12, 19,20, 17,18, 13,14]
      h.each { |k,v| assert_equal( k+1, v ) }
    end
  end # class Test_TofuHash
  
  # copied from /ruby/src/ruby-1.8.6/test/ruby/test_hash.rb
  # modified to use TofuHash instead of Hash
  class TestHash < Test::Unit::TestCase
    def test_hash
      x = TofuHash[1=>2, 2=>4, 3=>6]
      y = TofuHash[1, 2, 2, 4, 3, 6]
      assert_equal(2, x[1])

      assert(begin
          for k,v in y
            raise if k*2 != v
          end
          true
        rescue
          false
        end)

      assert_equal(3, x.length)
      assert(x.has_key?(1))
      assert(x.has_value?(4))
      assert_equal([4,6], x.values_at(2,3))
      assert_equal(TofuHash[1=>2, 2=>4, 3=>6], x)

      z = y.keys.join(":")
      assert_equal("1:2:3", z)

      z = y.values.join(":")
      assert_equal("2:4:6", z)
      assert_equal(x, y)

      y.shift
      assert_equal(2, y.length)

      z = [1,2]
      y[z] = 256
      assert_equal(256, y[z])

      x = TofuHash.new(0)
      x[1] = 1
      assert_equal(1, x[1])
      assert_equal(0, x[2])

      x = TofuHash.new([])
      assert_equal([], x[22])
      assert_same(x[22], x[22])

      x = TofuHash.new{[]}
      assert_equal([], x[22])
      assert_not_same(x[22], x[22])

      x = TofuHash.new{|h,k| z = k; h[k] = k*2}
      z = 0
      assert_equal(44, x[22])
      assert_equal(22, z)
      z = 0
      assert_equal(44, x[22])
      assert_equal(0, z)
      x.default = 5
      assert_equal(5, x[23])

      x = TofuHash.new
      def x.default(k)
        k = decode(k)
        $z = k
        self[k] = k*2
      end
      $z = 0
      assert_equal(44, x[22])
      assert_equal(22, $z)
      $z = 0
      assert_equal(44, x[22])
      assert_equal(0, $z)
    end

    class MyClass
      attr_reader :str
      def initialize(str)
        @str = str
      end
      def eql?(o)
        o.is_a?(MyClass) && str == o.str
      end
      def hash
        @str.hash
      end
    end

    def test_ri_hash_code
      a = MyClass.new("some string")
      b = MyClass.new("some string")
      assert( a.eql?( b ) )  #=> true

      h = TofuHash.new #was: h={}

      h[a] = 1
      assert_equal( h[a],1 )      #=> 1
      assert_equal( h[b],1 )      #=> 1

      h[b] = 2
      assert_equal( h[a],2 )      #=> 2
      assert_equal( h[b],2 )      #=> 2
    end

    def test_ri_hash_new_code
      h = TofuHash.new("Go Fish")
      h["a"] = 100
      h["b"] = 200
      assert_equal( h["a"], 100 )           #=> 100
      assert_equal( h["c"], "Go Fish" )           #=> "Go Fish"
      # The following alters the single default object
      assert_equal( h["c"].upcase!, "GO FISH" )   #=> "GO FISH"
      assert_equal( h["d"], "GO FISH" )           #=> "GO FISH"
      assert_equal( h.keys, ["a","b"] )           #=> ["a", "b"]

      # While this creates a new default object each time
      h = TofuHash.new { |hash, key| hash[key] = "Go Fish: #{key}" }
      assert_equal( h["c"], "Go Fish: c" )           #=> "Go Fish: c"
      assert_equal( h["c"].upcase!, "GO FISH: C" )   #=> "GO FISH: C"
      assert_equal( h["d"], "Go Fish: d" )           #=> "Go Fish: d"
      assert_equal( h.keys, ["c","d"] )           #=> ["c", "d"]
    end

    def test_ri_hash_square_bracket_code
      assert_equal( TofuHash["a", 100, "b", 200], {"a"=>100, "b"=>200} )       #=> {"a"=>100, "b"=>200}
      assert_equal( TofuHash["a" => 100, "b" => 200], {"a"=>100, "b"=>200} )    #=> {"a"=>100, "b"=>200}
    end

    def test_to_a
      hash = TofuHash["a" => 2, "b" => 1]
      assert_equal [["a",2],["b",1]], hash.to_a
    end

    def test_ri_to_a
      h = { "c" => 300, "a" => 100, "d" => 400, "c" => 300  }
      result = h.to_a
      sorted = h.to_a.sort { |a,b| a[0] <=> b[0] }
      assert_equal( [['a',100],['c',300],['d',400]], sorted )
    end
    
    def test_include?
      hash =  TofuHash["a" => 2, "b" => 1]
      assert( hash.include?( 'a' ))
    end
    
    def test_ri_include?
      h = { "a" => 100, "b" => 200 }
      assert( h.has_key?("a") )
      assert_equal( false, h.has_key?("z"))
    end

    def test_ri_delete_if
      h =  TofuHash["a" => 100, "b" => 200,  "c" => 300]
      h.delete_if { |key,value| key >= 'b' }
      assert_equal TofuHash['a' => 100], h
    end

    def test_delete_unless
      hash =  TofuHash["a" => 2, "b" => 1]
      hash.delete_unless { |k,v| k == 'b' }
      assert_equal TofuHash['b' => 1], hash
    end

    def test_ri_hash_equality
=begin
    TODO: KNOWN ISSUE, Hash doesn't know how to compare to TofuHash.
=end
      h1 = TofuHash[ "a" => 1, "c" => 2 ]
      h2 = { 7 => 35, "c" => 2, "a" => 1 }
      h3 = TofuHash[ "a" => 1, "c" => 2, 7 => 35 ]
      h4 = TofuHash[ "a" => 1, "d" => 2, "f" => 35 ]
      assert_equal( h1 == h2, false )   #=> false
#    assert_equal( h2 == h3, true )   #=> true; however see issue
      assert_equal( h3 == h4, false )   #=> false
    end
    
    def test_ri_element_reference
      h = TofuHash[ "a" => 100, "b" => 200 ]
      assert_equal( h["a"], 100 )
      assert_equal( h["b"], 200 )
      
      # case-insensitive access...
      assert_equal( h["A"], 100 )
      assert_equal( h["B"], 200 )

      # indifferent access...
      assert_equal( h[:a], 100 )
      assert_equal( h[:b], 200 )
      
      # both
      assert_equal( h[:A], 100 )
      assert_equal( h[:B], 200 )
    end
    
    def test_ri_element_assignment
      h = TofuHash[ "a" => 100, "b" => 200 ]
      h["a"] = 9
      h["c"] = 4
      
      # tofu examples...
      h[:a] = 10
      h["D"] = 5
      h[:e] = 6
      h[:F] = 7
      assert_equal( h, {"a"=>10, "b"=>200, "c"=>4, "d"=>5, "e"=>6, "f"=>7} )
      assert_equal( h, {:a=>10, "b"=>200, "c"=>4, "D"=>5, :e=>6, :F=>7} )
    end
    
    def test_ri_store
      h = TofuHash[ "a" => 100, "b" => 200 ]
      h.store("a",9)
      h.store("c",4)
      
      # tofu examples...
      h.store(:a,10)
      h.store("D",5)
      h.store(:e,6)
      h.store(:F,7)
      assert_equal( h, {"a"=>10, "b"=>200, "c"=>4, "d"=>5, "e"=>6, "f"=>7} )
      assert_equal( h, {:a=>10, "b"=>200, "c"=>4, "D"=>5, :e=>6, :F=>7} )
    end
    
    def test_ri_clear
      h = TofuHash[ "a" => 100, "b" => 200 ]
      h.clear
      assert_equal( h, {} )
    end
    
    def test_ri_default_access
      h = TofuHash.new
      assert_nil( h.default )
      assert_nil( h.default(2) )
      
      h = TofuHash.new("cat")
      assert_equal( h.default, "cat" )
      assert_equal( h.default(2), "cat" )

      h = TofuHash.new {|hash,key| hash[key] = key.to_i*10}
      assert_equal( h.default, 0 )
      assert_equal( h.default(2), 20 )
    end
    
    def test_ri_default_assignment
      h = TofuHash[ "a" => 100, "b" => 200 ]
      h.default = "Go fish"
      assert_equal( 100, h["a"] )
      assert_equal( "Go fish", h["z"] )
      h.default = proc do |hash, key|
        hash[key] = key + key
      end
      assert( h[2].is_a?( Proc ))
      assert( h["cat"].is_a?( Proc ))
      assert_same( h[2], h["cat"] )
    end
    
    def test_ri_default_proc
      h = TofuHash.new {|h,k| h[k] = k*k }
      p = h.default_proc
      assert( p.is_a?( Proc ))
      a = []
      p.call( a, 2 )
      assert_equal( [nil, nil, 4], a )
    end

    def test_ri_delete
      h = TofuHash[ "a" => 100, "b" => 200 ]
      assert_equal( h.delete("a"), 100 )
      assert_equal( h.delete("z"), nil )
      assert_equal( h.delete("z") { |el| "#{el} not found" }, "z not found" )
      assert_equal( h, { "b" => 200 } )
    end

    def test_ri_each
      results = []
      h = TofuHash[ "a" => 100, "b" => 200 ]
      h.each {|key, value| results << "#{key} is #{value}" }
      assert_equal( ["a is 100", "b is 200"], results) 
    end
    
    def test_ri_each_key
      results = []
      h = TofuHash[ "a" => 100, "b" => 200 ]
      h.each_key {|key| results << key }
      assert_equal( ["a", "b"], results) 
    end
    
    def test_ri_each_pair
      results = []
      h = TofuHash[ "a" => 100, "b" => 200 ]
      h.each_pair {|key, value| results << "#{key} is #{value}" }
      assert_equal( ["a is 100", "b is 200"], results) 
    end
    
    def test_ri_each_value
      results = []
      h = TofuHash[ "a" => 100, "b" => 200 ]
      h.each_value {|value| results << value }
      assert_equal( [100,200], results) 
    end
    
    def test_ri_empty?
      h = TofuHash[ "a" => 100, "b" => 200 ]
      assert( !h.empty? )
      h = TofuHash[]
      assert( h.empty? )
    end
    
    def test_ri_fetch
      h = TofuHash[ "a" => 100, "b" => 200 ]
      assert_equal( 100, h.fetch("a"))
      assert_equal( "go fish", h.fetch("z", "go fish"))
      assert_equal( "go fish, z", h.fetch("z") { |el| "go fish, #{el}"})
      # supress expected warning message from clutter test output
      old_VERBOSE = $VERBOSE
      $VERBOSE = nil
      #note, this will generate a warning "block supersedes default value argument"
      assert_equal( "go fish, z", h.fetch("z", 99) { |el| "go fish, #{el}"})
      $VERBOSE = old_VERBOSE
      assert_raise IndexError do
        h.fetch("z")
      end
    end
    
    def test_ri_has_key
      h = TofuHash[ "a" => 100, "b" => 200 ]
      assert( h.has_key?( "a" ) )
      assert( h.has_key?( :a ) )
      assert( h.has_key?( "A" ) )
      assert( h.has_key?( :A ) )
      assert( !h.has_key?( "z" ) )
    end
    
    def test_ri_include
      h = TofuHash[ "a" => 100, "b" => 200 ]
      assert( h.include?( "a" ) )
      assert( h.include?( :a ) )
      assert( h.include?( "A" ) )
      assert( h.include?( :A ) )
      assert( !h.include?( "z" ) )
    end

    def test_ri_key_question
      h = TofuHash[ "a" => 100, "b" => 200 ]
      assert( h.key?( "a" ) )
      assert( h.key?( :a ) )
      assert( h.key?( "A" ) )
      assert( h.key?( :A ) )
      assert( !h.key?( "z" ) )
    end
    
    def test_ri_member_question
      h = TofuHash[ "a" => 100, "b" => 200 ]
      assert( h.member?( "a" ) )
      assert( h.member?( :a ) )
      assert( h.member?( "A" ) )
      assert( h.member?( :A ) )
      assert( !h.member?( "z" ) )
    end
    
    def test_ri_has_value
      h = TofuHash[ "a" => 100, "b" => 200 ]
      assert( h.has_value?( 100 ))
      assert( !h.has_value?( 999 ))
    end

    def test_ri_value_question
      h = TofuHash[ "a" => 100, "b" => 200 ]
      assert( h.value?( 100 ))
      assert( !h.value?( 999 ))
    end
    
    def test_ri_index
      h = TofuHash[ "a" => 100, "b" => 200 ]
      assert_equal( "b", h.index( 200 ))
      assert_equal( nil, h.index( 999 ))
    end
    
    def test_ri_replace
      h = TofuHash[ "a" => 100, "b" => 200 ]
      h2 = {"c" => 300, "d" => 400 }
      h.replace( h2 )
      assert_equal( h, h2 )
      h2["c"] = 999
      assert_equal( 300, h["c"] )
      h.each_key_encoded do |key|
        assert_instance_of( TofuKey, key )
      end
    end
    
    def test_ri_select
      h = TofuHash[ "a" => 100, "b" => 200, "c" => 300 ]
      assert( [["b", 200], ["c", 300]], h.select {|k,v| k > "a"} )
      assert( [["a", 100]], h.select {|k,v| v < 200} )
    end
    
    def test_ri_shift
      h = TofuHash[ 1 => "a", 2 => "b", 3 => "c" ]
      assert_equal( [1,"a"], h.shift )
      assert_equal( h, {2 => "b", 3 => "c"} )
    end
    
    def test_ri_length_and_size
      h = TofuHash[ "d" => 100, "a" => 200, "v" => 300, "e" => 400 ]
      assert_equal( 4, h.length )
      assert_equal( 4, h.size )
      assert_equal( 200, h.delete("a") )
      assert_equal( 3, h.length )
      assert_equal( 3, h.size )
    end

    def test_ri_sort
      h = TofuHash[ "a" => 20, "b" => 30, "c" => 10  ]
      assert_equal( [["a", 20], ["b", 30], ["c", 10]], h.sort )
      assert_equal( [["c", 10], ["a", 20], ["b", 30]], h.sort {|a,b| a[1]<=>b[1]} )
    end
  end # class TestHash
end # module TofuHash
