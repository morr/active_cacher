require 'spec_helper'

class A
  def initialize id
    @calls = 0
    @id = id
  end

  def foo
    @calls += 1
    "result A #{@id} #{@calls}"
  end
end

class B < A
  prepend ActiveCacher.instance
  instance_cache :foo
end

class C < A
  prepend ActiveCacher.instance
  instance_cache :foo

  def foo
    @calls += 1
    "result C #{@id} #{@calls}"
  end
end

describe ActiveCacher do
  describe 'no cache' do
    let(:a) { A.new :a }
    it 'does not cache' do
      expect(a.foo).to eq 'result A a 1'
      expect(a.foo).to eq 'result A a 2'
    end
  end

  describe 'with cacher' do
    let(:b) { B.new :b }
    let(:c) { C.new :c }

    before { b.foo }

    it 'caches calls' do
      expect(b.foo).to eq 'result A b 1'
    end

    it 'stores cached value in instance variable' do
      expect(b.instance_variable_get('@__foo')).to eq 'result A b 1'
    end

    it 'does not clases with other caceable objects' do
      expect(c.foo).to eq 'result C c 1'
      expect(b.foo).to eq 'result A b 1'
      expect(c.foo).to eq 'result C c 1'
    end
  end
end
