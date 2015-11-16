After awhile of rolling around in many variations of converting hash keys from strings to symbols I realized that the best solution in fact comes from the `tap` method.  Tap returns self and for someone aspiring to write a recursive method this is the shiznit!  I first started by brute forcing the deal and wow was it ugly.  Like Jabba the Hut ugly.  So i went in on it and started some research.  After some sleuthing I found the perfect solution from [here](http://apidock.com/rails/v4.0.2/Hash/deep_symbolize_keys) from EdvardM.  Thanks man.  You the real mvp.  The first code is my ugly stuff.  The second is the beautiful recursion.


        param_step_one = provider_params.symbolize_keys
        nested_hash = param_step_one.detect { |m| m.second.respond_to?(:keys) }.second.symbolize_keys
        key = param_step_one.detect { |m| m.second.respond_to?(:keys) }.first
        param_step_one[key] = nested_hash
        provider_params = param_step_one

And cue swan lake.
# Hash potatoes


      def symbolize_recursive hash
        {}.tap do |h|
          hash.each { |key, value|  h[key.to_sym] = map_value(value) }
        end
      end

      def map_value obj
        if obj.kind_of?(Hash)
          symbolize_recursive obj
        else
          obj
        end
      end

Awww yiss.
