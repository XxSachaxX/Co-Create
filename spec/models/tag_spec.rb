require "rails_helper"

RSpec.describe Tag, type: :model do
  describe "validations" do
    describe "when name is nil" do
      let(:tag) { FactoryBot.build(:tag, name: nil) }

      it "is invalid" do
        expect(tag).not_to be_valid
        expect(tag.errors[:name]).to include("can't be blank")
      end
    end

    describe "when name is not unique (case insensitive)" do
      let!(:existing_tag) { FactoryBot.create(:tag, name: "rails") }
      let(:tag) { FactoryBot.build(:tag, name: "Rails") }

      it "is invalid" do
        expect(tag).not_to be_valid
        expect(tag.errors[:name]).to include("has already been taken")
      end
    end

    describe "when name is too short" do
      let(:tag) { FactoryBot.build(:tag, name: "a") }

      it "is invalid" do
        expect(tag).not_to be_valid
        expect(tag.errors[:name]).to include("is too short (minimum is 2 characters)")
      end
    end

    describe "when name is too long" do
      let(:tag) { FactoryBot.build(:tag, name: "a" * 31) }

      it "is invalid" do
        expect(tag).not_to be_valid
        expect(tag.errors[:name]).to include("is too long (maximum is 30 characters)")
      end
    end

    describe "name format validation" do
      describe "when name is lowercase alphanumeric with hyphens" do
        it "is valid" do
          expect(FactoryBot.build(:tag, name: "rails")).to be_valid
          expect(FactoryBot.build(:tag, name: "ruby-on-rails")).to be_valid
          expect(FactoryBot.build(:tag, name: "web3")).to be_valid
        end
      end

      describe "when name contains special characters after normalization" do
        it "is invalid" do
          expect(FactoryBot.build(:tag, name: "c++")).not_to be_valid
          expect(FactoryBot.build(:tag, name: "rails_dev")).not_to be_valid
          expect(FactoryBot.build(:tag, name: "rails.js")).not_to be_valid
        end
      end
    end
  end

  describe "associations" do
    let(:tag) { FactoryBot.create(:tag) }

    it "has many project_tags" do
      expect(tag).to respond_to(:project_tags)
    end

    it "has many projects through project_tags" do
      expect(tag).to respond_to(:projects)
    end
  end

  describe "callbacks" do
    describe "normalize_name" do
      describe "when name has leading and trailing whitespace" do
        let(:tag) { FactoryBot.create(:tag, name: "  rails  ") }

        it "strips whitespace" do
          expect(tag.name).to eq("rails")
        end
      end

      describe "when name has uppercase letters" do
        let(:tag) { FactoryBot.create(:tag, name: "Rails") }

        it "converts to lowercase" do
          expect(tag.name).to eq("rails")
        end
      end

      describe "when name has spaces" do
        let(:tag) { FactoryBot.create(:tag, name: "Ruby on Rails") }

        it "converts spaces to hyphens" do
          expect(tag.name).to eq("ruby-on-rails")
        end
      end

      describe "when name has multiple spaces" do
        let(:tag) { FactoryBot.create(:tag, name: "web    development") }

        it "converts to single hyphens" do
          expect(tag.name).to eq("web-development")
        end
      end

      describe "when name needs all normalization" do
        let(:tag) { FactoryBot.create(:tag, name: "  Ruby on Rails  ") }

        it "handles all normalization together" do
          expect(tag.name).to eq("ruby-on-rails")
        end
      end
    end
  end

  describe "scopes" do
    describe ".popular" do
      let!(:popular_tag) { FactoryBot.create(:tag, name: "rails", projects_count: 10) }
      let!(:unpopular_tag) { FactoryBot.create(:tag, name: "python", projects_count: 1) }
      let!(:medium_tag) { FactoryBot.create(:tag, name: "javascript", projects_count: 5) }

      it "orders tags by projects_count in descending order" do
        expect(Tag.popular).to eq([ popular_tag, medium_tag, unpopular_tag ])
      end
    end

    describe ".alphabetical" do
      let!(:zebra_tag) { FactoryBot.create(:tag, name: "zebra") }
      let!(:alpha_tag) { FactoryBot.create(:tag, name: "alpha") }
      let!(:beta_tag) { FactoryBot.create(:tag, name: "beta") }

      it "orders tags by name in ascending order" do
        expect(Tag.alphabetical).to eq([ alpha_tag, beta_tag, zebra_tag ])
      end
    end

    describe ".search" do
      let!(:rails_tag) { FactoryBot.create(:tag, name: "rails") }
      let!(:ruby_tag) { FactoryBot.create(:tag, name: "ruby") }
      let!(:javascript_tag) { FactoryBot.create(:tag, name: "javascript") }

      describe "when query matches tag name" do
        it "returns matching tags" do
          results = Tag.search("rail")
          expect(results).to include(rails_tag)
          expect(results).not_to include(ruby_tag)
          expect(results).not_to include(javascript_tag)
        end
      end

      describe "when query is uppercase" do
        it "performs case insensitive search" do
          results = Tag.search("RAIL")
          expect(results).to include(rails_tag)
        end
      end

      describe "when query matches multiple tags" do
        it "returns all matching tags" do
          results = Tag.search("java")
          expect(results).to include(javascript_tag)
        end
      end

      describe "when query is blank" do
        it "returns all tags" do
          expect(Tag.search("").count).to eq(3)
          expect(Tag.search(nil).count).to eq(3)
        end
      end
    end
  end

  describe "#to_param" do
    let(:tag) { FactoryBot.create(:tag, name: "ruby-on-rails") }

    it "returns parameterized name for URLs" do
      expect(tag.to_param).to eq("ruby-on-rails")
    end
  end
end
