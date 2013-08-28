# Copyright (C) 2013 Salvatore Sanfilippo <antirez@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'rubygems'
require 'redis'
require 'memcache'

ValuesDistribution= [
 [0.020957439173186,0..135],
 [0.021100983277112,137..175],
 [0.021280413407019,177..223],
 [0.024079523433575,225..439],
 [0.092191200746429,441..551],
 [0.14623555587454,553..695],
 [0.18937055910428,697..871],
 [0.22367759994258,873..1099],
 [0.2240364602024,1101..1299],
 [0.22425177635829,1301..1699],
 [0.22425177635829,1701..2099],
 [0.22428766238427,2101..2599],
 [0.22428766238427,2601..3299],
 [0.22446709251417,3301..4099],
 [0.22453886456614,4101..5199],
 [0.22511304098184,5201..6399],
 [0.22708677241082,6401..8099],
 [0.22812746716429,8101..10099],
 [0.23103423526879,10101..12599],
 [0.23562764659442,12601..15799],
 [0.24843895786981,15801..19699],
 [0.26462355558745,19701..24599],
 [0.41739036819063,24601..30799],
 [0.4761716787483,30801..38499],
 [0.61479939711476,38501..48099],
 [0.66543457977464,48101..60199],
 [0.70788774851073,60201..75199],
 [0.71901241656499,75201..93999],
 [0.85250843321611,94001..117499],
 [0.88372927582,117501..146899],
 [0.96967630804565,146901..183599],
 [0.99138735376444,183601..229499],
 [0.99881576114261,229501..286899],
 [0.99992822794804,286901..358599],
 [1,358601..448199]
]

def get_value_size
    r = rand()
    ValuesDistribution.each{|p|
        if p[0] > r then
            return p[1].begin + rand(p[1].end-p[1].begin)
        end
    }
end

def test_redis
    r = Redis.new(:port => 10000)
    r.flushall
    rawsize = 0
    while true
        break if r.info['used_memory'].to_i >= 1024*1024*400
        key = "key:"+("x"*80)+rand(1000000000).to_s
        value_size = get_value_size()
        value = "A" * value_size
        rawsize += value_size + 100 # Key size + payload
        r.set(key,value)
    end
    puts "Memory used: #{r.info['used_memory_human']}"
    puts "Keys stored: #{r.dbsize}"
    puts "Raw bytes: #{rawsize}"
    puts "Efficiency: #{rawsize.to_f/r.info['used_memory'].to_i}"
end

def test_memcache
    puts "Make sure to run memcached with -m 400 -M"
    m = MemCache.new('localhost:11211')
    rawsize = 0
    keys = 0
    while true
        key = "key:"+("x"*80)+rand(1000000000).to_s
        value_size = get_value_size()
        value = "A" * value_size
        rawsize += value_size + 100 # Key size + payload
        begin
            m.set(key,value)
        rescue MemCache::MemCacheError
            break
        end
        keys += 1
    end
    puts "Memory used: 400MB (use memcached -m 400 -M)"
    puts "Keys stored: #{keys}"
    puts "Raw bytes: #{rawsize}"
    puts "Efficiency: #{rawsize.to_f/(400*1024*1024)}"
end

puts "Please uncomment 'test_memcache' or 'test_redis'"
# test_memcache
# test_redis
