# frozen_string_literal: true

require ::File.expand_path("../../test_helper", __FILE__)

module Capapi
  class CapapiObjectTest < Test::Unit::TestCase
    should "implement #==" do
      obj1 = Capapi::CapapiObject.construct_from(id: 1, foo: "bar")
      obj2 = Capapi::CapapiObject.construct_from(id: 1, foo: "bar")
      obj3 = Capapi::CapapiObject.construct_from(id: 1, foo: "rab")

      assert obj1 == obj2
      refute obj1 == obj3
    end

    should "implement #respond_to" do
      obj = Capapi::CapapiObject.construct_from(id: 1, foo: "bar")
      assert obj.respond_to?(:id)
      assert obj.respond_to?(:foo)
      assert !obj.respond_to?(:baz)
    end

    should "marshal be insensitive to strings vs. symbols when constructin" do
      obj = Capapi::CapapiObject.construct_from(:id => 1, "name" => "Capapi")
      assert_equal 1, obj[:id]
      assert_equal "Capapi", obj[:name]
    end

    context "#deep_copy" do
      should "produce a deep copy" do
        opts = {
          api_base: Capapi.api_base,
          api_key: "apikey",
        }
        values = {
          id: 1,
          name: "Capapi",
          arr: [
            CapapiObject.construct_from({ id: "index0" }, opts),
            "index1",
            2,
          ],
          map: {
            :"0" => CapapiObject.construct_from({ id: "index0" }, opts),
            :"1" => "index1",
            :"2" => 2,
          },
        }

        # it's not good to test methods with `#send` like this, but I've done
        # it in the interest of trying to keep `.deep_copy` as internal as
        # possible
        copy_values = Capapi::CapapiObject.send(:deep_copy, values)

        # we can't compare the hashes directly because they have embedded
        # objects which are different from each other
        assert_equal values[:id], copy_values[:id]
        assert_equal values[:name], copy_values[:name]

        assert_equal values[:arr].length, copy_values[:arr].length

        # internal values of the copied CapapiObject should be the same
        # (including opts), but the object itself should be new (hence the
        # refutation of equality on #object_id)
        assert_equal values[:arr][0][:id], copy_values[:arr][0][:id]
        refute_equal values[:arr][0].object_id, copy_values[:arr][0].object_id
        assert_equal values[:arr][0].instance_variable_get(:@opts),
                     copy_values[:arr][0].instance_variable_get(:@opts)

        # scalars however, can be compared
        assert_equal values[:arr][1], copy_values[:arr][1]
        assert_equal values[:arr][2], copy_values[:arr][2]

        # and a similar story with the hash
        assert_equal values[:map].keys, copy_values[:map].keys
        assert_equal values[:map][:"0"][:id], copy_values[:map][:"0"][:id]
        refute_equal values[:map][:"0"].object_id, copy_values[:map][:"0"].object_id
        assert_equal values[:map][:"0"].instance_variable_get(:@opts),
                     copy_values[:map][:"0"].instance_variable_get(:@opts)
        assert_equal values[:map][:"1"], copy_values[:map][:"1"]
        assert_equal values[:map][:"2"], copy_values[:map][:"2"]
      end

      should "not copy a client" do
        opts = {
          api_key: "apikey",
          client: CapapiClient.active_client,
        }
        values = { id: 1, name: "Capapi" }

        obj = Capapi::CapapiObject.construct_from(values, opts)
        copy_obj = Capapi::CapapiObject.send(:deep_copy, obj)

        assert_equal values, copy_obj.instance_variable_get(:@values)
        assert_equal opts.reject { |k, _v| k == :client },
                     copy_obj.instance_variable_get(:@opts)
      end

      should "return an instance of the same class" do
        class TestObject < Capapi::CapapiObject; end

        obj = TestObject.construct_from(id: 1)
        copy_obj = obj.class.send(:deep_copy, obj)

        assert_equal obj.class, copy_obj.class
      end
    end

    context "#to_hash" do
      should "skip calling to_hash on nil" do
        module NilWithToHash
          def to_hash
            raise "Can't call to_hash on nil"
          end
        end
        # include is private in Ruby 2.0
        NilClass.send(:include, NilWithToHash)

        hash_with_nil = { id: 3, foo: nil }
        obj = CapapiObject.construct_from(hash_with_nil)
        expected_hash = { id: 3, foo: nil }
        assert_equal expected_hash, obj.to_hash
      end

      should "recursively call to_hash on its values" do
        # deep nested hash (when contained in an array) or CapapiObject
        nested_hash = { id: 7, foo: "bar" }
        nested = Capapi::CapapiObject.construct_from(nested_hash)

        obj = Capapi::CapapiObject.construct_from(id: 1,
                                                  # simple hash that contains a CapapiObject to help us test deep
                                                  # recursion
                                                  nested: { object: "list", data: [nested] },
                                                  list: [nested])

        expected_hash = {
          id: 1,
          nested: { object: "list", data: [nested_hash] },
          list: [nested_hash],
        }
        assert_equal expected_hash, obj.to_hash
      end
    end

    should "assign question mark accessors for booleans" do
      obj = Capapi::CapapiObject.construct_from(id: 1, bool: true, not_bool: "bar")
      assert obj.respond_to?(:bool?)
      assert obj.bool?
      refute obj.respond_to?(:not_bool?)
    end

    should "assign question mark accessors for booleans added after initialization" do
      obj = Capapi::CapapiObject.new
      obj.bool = true
      assert obj.respond_to?(:bool?)
      assert obj.bool?
    end

    should "mass assign values with #update_attributes" do
      obj = Capapi::CapapiObject.construct_from(id: 1, name: "Capapi")
      obj.update_attributes(name: "CAPAPI")
      assert_equal "CAPAPI", obj.name

      # unfortunately, we even assign unknown properties to duplicate the
      # behavior that we currently have via magic accessors with
      # method_missing
      obj.update_attributes(unknown: "foo")
      assert_equal "foo", obj.unknown
    end

    should "#update_attributes with a hash" do
      obj = Capapi::CapapiObject.construct_from({})
      obj.update_attributes(metadata: { foo: "bar" })
      assert_equal Capapi::CapapiObject, obj.metadata.class
    end

    should "create accessors when #update_attributes is called" do
      obj = Capapi::CapapiObject.construct_from({})
      assert_equal false, obj.send(:metaclass).method_defined?(:foo)
      obj.update_attributes(foo: "bar")
      assert_equal true, obj.send(:metaclass).method_defined?(:foo)
    end

    should "pass opts down to children when initializing" do
      opts = { custom: "opts" }

      # customer comes with a `sources` list that makes a convenient object to
      # perform tests on
      obj = Capapi::CapapiObject.construct_from({
        sources: [
          {},
        ],
      }, opts)

      source = obj.sources.first
      # Pulling `@opts` as an instance variable here is not ideal, but it's
      # important enough argument that the test here is worth it. we should
      # consider exposing it publicly on a future pull (and possibly renaming
      # it to something more useful).
      assert_equal opts, source.instance_variable_get(:@opts)
    end

    should "#to_s will call to_s for all embedded capapi objects" do
      obj = Capapi::CapapiObject.construct_from(id: "id",
                                                # embeded list object
                                                refunds: Capapi::ListObject.construct_from(data: [
                                                  # embedded object in list
                                                  Capapi::CapapiObject.construct_from(id: "id",
                                                                                      # embedded object in an object in a list object
                                                                                      metadata: Capapi::CapapiObject.construct_from(foo: "bar")),
                                                ]),
                                                # embeded capapi object
                                                metadata: Capapi::CapapiObject.construct_from(foo: "bar"))
      expected = JSON.pretty_generate(id: "id",
                                      refunds: {
                                        data: [
                                          { id: "id", metadata: { foo: "bar" } },
                                        ],
                                      },
                                      metadata: { foo: "bar" })

      assert_equal(expected, obj.to_s)
    end

    should "error on setting a property to an empty string" do
      obj = Capapi::CapapiObject.construct_from(foo: "bar")
      e = assert_raises ArgumentError do
        obj.foo = ""
      end
      assert_match(/\(object\).foo = nil/, e.message)
    end

    should "marshal and unmarshal using custom encoder and decoder" do
      obj = Capapi::CapapiObject.construct_from(
        { id: 1, name: "Capapi" },
        api_key: "apikey",
        client: CapapiClient.active_client
      )
      m = Marshal.load(Marshal.dump(obj))
      assert_equal 1, m.id
      assert_equal "Capapi", m.name
      expected_hash = { api_key: "apikey" }
      assert_equal expected_hash, m.instance_variable_get("@opts")
    end

    context "#method" do
      should "act as a getter if no arguments are provided" do
        obj = Capapi::CapapiObject.construct_from(id: 1, method: "foo")
        assert_equal "foo", obj.method
      end

      should "call Object#method if an argument is provided" do
        obj = Capapi::CapapiObject.construct_from(id: 1, method: "foo")
        assert obj.method(:id).is_a?(Method)
      end
    end
  end
end
