require 'spec_helper'

describe ActiveCacher do
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

  module Rails
    def self.cache
      @cache ||= ::ActiveSupport::Cache::MemoryStore.new
    end
  end
  class D < A
    prepend ActiveCacher.instance
    rails_cache :foo

    def to_param
      self.class.name
    end
  end

  describe 'no cache' do
    let(:a) { A.new :a }
    it 'does not cache' do
      expect(a.foo).to eq 'result A a 1'
      expect(a.foo).to eq 'result A a 2'
    end
  end

  describe 'with cacher' do
    describe '#instance_cache' do
      let(:b) { B.new :b }
      let(:c) { C.new :c }

      before { b.foo }

      it 'caches calls' do
        expect(b.foo).to eq 'result A b 1'
      end

      it 'stores cached value in instance variable' do
        expect(b.instance_variable_get('@__foo')).to eq 'result A b 1'
      end

      it 'does not intersect with other caceable objects' do
        expect(c.foo).to eq 'result C c 1'
        expect(b.foo).to eq 'result A b 1'
        expect(c.foo).to eq 'result C c 1'
      end
    end

    describe '#rails_cache' do
      let(:d) { D.new :d }

      it 'caches calls' do
        expect(d.foo).to eq 'result A d 1'
        expect(d.foo).to eq 'result A d 1'
      end

      it 'caches in Rails.cache.only once' do
        expect(d.foo).to eq 'result A d 1'
        expect(D.new(:zzz).foo).to eq 'result A d 1'
      end
    end
  end
end
