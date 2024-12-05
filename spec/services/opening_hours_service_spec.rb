# spec/services/opening_hours_service_spec.rb
require 'rails_helper'

RSpec.describe OpeningHoursService, type: :service do
  let(:pharmacy1) { create(:pharmacy, name: "pharmacy 1") }
  let(:pharmacy2) { create(:pharmacy, name: "pharmacy 2") }
  let(:pharmacy3) { create(:pharmacy, name: "pharmacy 3") }
  let(:pharmacy4) { create(:pharmacy, name: "pharmacy 4") }

  describe "#call" do
    context "when querying available pharmacies with a specific time" do
      before do
        create(:opening_hour, pharmacy: pharmacy1, open: "08:00", close: "17:00")
        create(:opening_hour, pharmacy: pharmacy2, open: "10:00", close: "18:00")
        create(:opening_hour, pharmacy: pharmacy3, open: "20:00", close: "02:00")
        create(:opening_hour, pharmacy: pharmacy4, open: "12:00", close: "03:00")
      end

      it "returns pharmacy 1 at 08:00" do
        result = described_class.call(time: "08:00")
        expect(result.success?).to be true
        expect(result.payload.map { |pharmacy| pharmacy[:pharmacy_name] }).to contain_exactly("pharmacy 1")
      end

      it "returns pharmacies 1 and 2 at 10:00" do
        result = described_class.call(time: "10:00")
        expect(result.success?).to be true
        expect(result.payload.map { |pharmacy| pharmacy[:pharmacy_name] }).to contain_exactly("pharmacy 1", "pharmacy 2")
      end

      it "returns pharmacies 1, 2, and 4 at 12:00" do
        result = described_class.call(time: "12:00")
        expect(result.success?).to be true
        expect(result.payload.map { |pharmacy| pharmacy[:pharmacy_name] }).to contain_exactly("pharmacy 1", "pharmacy 2", "pharmacy 4")
      end

      it "returns pharmacies 2 and 4 at 17:00" do
        result = described_class.call(time: "17:00")
        expect(result.success?).to be true
        expect(result.payload.map { |pharmacy| pharmacy[:pharmacy_name] }).to contain_exactly("pharmacy 2", "pharmacy 4")
      end

      it "returns pharmacies 3 and 4 at 20:00" do
        result = described_class.call(time: "20:00")
        expect(result.success?).to be true
        expect(result.payload.map { |pharmacy| pharmacy[:pharmacy_name] }).to contain_exactly("pharmacy 3", "pharmacy 4")
      end

      it "returns pharmacies 4 at 02:00" do
        result = described_class.call(time: "02:00")
        expect(result.success?).to be true
        expect(result.payload.map { |pharmacy| pharmacy[:pharmacy_name] }).to contain_exactly("pharmacy 4")
      end

      it "returns no pharmacies at 06:00" do
        result = described_class.call(time: "06:00")
        expect(result.success?).to be true
        expect(result.payload).to be_empty
      end
    end

    context "when querying available pharmacies with a specific weekday" do
      before do
        create(:opening_hour, pharmacy: pharmacy1, open: "08:00", close: "17:00", weekday: 1)
        create(:opening_hour, pharmacy: pharmacy1, open: "08:00", close: "17:00", weekday: 2)
        create(:opening_hour, pharmacy: pharmacy1, open: "12:00", close: "17:00", weekday: 6)
      end

      it "returns tuesday's opening hours" do
        result = described_class.call(time: "08:00", weekday: 1)
        expect(result.success?).to be true
        expect(result.payload.map { |pharmacy| pharmacy[:weekdays] }).to contain_exactly("Tue"=>{:open_hour=>"08:00", :close_hour=>"17:00"})
      end

      it "returns no opening hours" do
        result = described_class.call(time: "08:00", weekday: 6)
        expect(result.success?).to be true
        expect(result.payload).to be_empty
      end
    end
  end
end
