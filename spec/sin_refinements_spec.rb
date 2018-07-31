require "spec_helper"

module ExtMod
  refine String do
    def bang
      "#{self}!!"
    end
  end
end

RSpec.describe SinRefinements do
  describe ".refining" do
    it "refines only passed Proc" do
      SinRefinements.refining(ExtMod) do
        expect("foo".bang).to eq("foo!!")
      end

      expect { "foo".bang }.to raise_error(NoMethodError)

      local_var = "hoge"
      SinRefinements.refining(ExtMod) do
        expect(local_var.bang).to eq("hoge!!")
      end
    end
  end
end
