require 'tofuhash'
require 'test/unit'

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

    def test_to_array
      hash = TofuHash["a" => 2, "b" => 1]
      assert_equal [["a",2],["b",1]], hash.to_a
    end

    def test_include_key
      hash =  TofuHash["a" => 2, "b" => 1]
      assert hash.include? 'a'
    end

    def test_delete_if
      hash =  TofuHash["a" => 2, "b" => 1]
      hash.delete_if { |k,v| k == 'b' }
      assert_equal TofuHash['a' => 2], hash
    end

    def test_delete_unless
      hash =  TofuHash["a" => 2, "b" => 1]
      hash.delete_unless { |k,v| k == 'b' }
      assert_equal TofuHash['b' => 1], hash
    end

    def test_ri_hash_equality
=begin
    TODO: KNOWN ISSUE, Hash doesn't know how to compare to TofuHash.

    h1 = TofuHash[ "a" => 1, "c" => 2 ]
    h2 = { 7 => 35, "c" => 2, "a" => 1 }
    h3 = TofuHash[ "a" => 1, "c" => 2, 7 => 35 ]
    h4 = TofuHash[ "a" => 1, "d" => 2, "f" => 35 ]
    puts "h1"
    assert_equal( h1 == h2, false )   #=> false
    puts "h2"
    assert_equal( h2 == h3, true )   #=>
    puts "h3"
    assert_equal( h3 == h4, false )   #=> false
=end
    end
  end # class TestHash
end # module TofuHash
