require 'test_helper'

class SerializerTest < Test::Unit::TestCase

  context 'YAML Serializer' do
    setup do
      # Hack: Assume that Fluxor already has_paper_trail from previous tests
      #Fluxor.instance_eval <<-END
        #has_paper_trail
      #END

      @fluxor = Fluxor.create :name => 'Some text.'
      @original_fluxor_attributes = @fluxor.send(:item_before_change).attributes # this is exactly what PaperTrail serializes
      @fluxor.update_attributes :name => 'Some more text.'
    end

    should 'work with the default yaml serializer' do
      # Normal behaviour
      assert_equal 2, @fluxor.versions.length
      assert_nil @fluxor.versions[0].reify
      assert_equal 'Some text.', @fluxor.versions[1].reify.name

      # Check values are stored as YAML.
      assert_equal @original_fluxor_attributes, YAML.load(@fluxor.versions[1].object)
      # This test can't consistently pass in Ruby1.8 because hashes do no preserve order, which means the order of the
      # attributes in the YAML can't be ensured.
      if RUBY_VERSION.to_f >= 1.9
        assert_equal YAML.dump(@original_fluxor_attributes), @fluxor.versions[1].object
      end
    end
  end

  context 'Custom Serializer' do
    setup do
      PaperTrail.configure do |config|
        config.serializer = PaperTrail::Serializers::Json
      end

      Fluxor.instance_eval <<-END
        has_paper_trail
      END

      @fluxor = Fluxor.create :name => 'Some text.'
      @original_fluxor_attributes = @fluxor.send(:item_before_change).attributes # this is exactly what PaperTrail serializes
      @fluxor.update_attributes :name => 'Some more text.'
    end

    teardown do
      PaperTrail.config.serializer = PaperTrail::Serializers::Yaml
    end

    should 'reify with custom serializer' do
      # Normal behaviour
      assert_equal 2, @fluxor.versions.length
      assert_nil @fluxor.versions[0].reify
      assert_equal 'Some text.', @fluxor.versions[1].reify.name

      # Check values are stored as JSON.
      assert_equal @original_fluxor_attributes, ActiveSupport::JSON.decode(@fluxor.versions[1].object)
      # This test can't consistently pass in Ruby1.8 because hashes do no preserve order, which means the order of the
      # attributes in the JSON can't be ensured.
      if RUBY_VERSION.to_f >= 1.9
        assert_equal ActiveSupport::JSON.encode(@original_fluxor_attributes), @fluxor.versions[1].object
      end
    end

  end

end
