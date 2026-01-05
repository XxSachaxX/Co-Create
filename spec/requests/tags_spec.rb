require "rails_helper"

RSpec.describe "Tags", type: :request do
  describe "GET /tags" do
    let!(:popular_tag) { FactoryBot.create(:tag, name: "rails", projects_count: 10) }
    let!(:medium_tag) { FactoryBot.create(:tag, name: "javascript", projects_count: 5) }
    let!(:unpopular_tag) { FactoryBot.create(:tag, name: "python", projects_count: 1) }

    describe "when requesting JSON format" do
      describe "without a search query" do
        it "returns tags ordered by popularity" do
          get tags_path, headers: { "Accept" => "application/json" }

          expect(response).to have_http_status(:success)
          json = JSON.parse(response.body)

          expect(json.first["name"]).to eq("rails")
          expect(json.first["projects_count"]).to eq(10)
        end

        describe "when more than 20 tags exist" do
          before { FactoryBot.create_list(:tag, 25) }

          it "limits results to 20 tags" do
            get tags_path, headers: { "Accept" => "application/json" }

            json = JSON.parse(response.body)
            expect(json.size).to be <= 20
          end
        end
      end

      describe "with a search query" do
        it "returns only tags matching the query" do
          get tags_path(query: "rail"), headers: { "Accept" => "application/json" }

          json = JSON.parse(response.body)
          tag_names = json.map { |t| t["name"] }

          expect(tag_names).to include("rails")
          expect(tag_names).not_to include("python", "javascript")
        end

        it "performs case-insensitive search" do
          get tags_path(query: "RAIL"), headers: { "Accept" => "application/json" }

          json = JSON.parse(response.body)
          expect(json.map { |t| t["name"] }).to include("rails")
        end

        it "returns empty array when no tags match" do
          get tags_path(query: "nonexistent"), headers: { "Accept" => "application/json" }

          json = JSON.parse(response.body)
          expect(json).to be_empty
        end
      end

      describe "with selected tags" do
        it "returns selected tags first, then popular tags" do
          get tags_path(selected: [ unpopular_tag.id ]), headers: { "Accept" => "application/json" }

          json = JSON.parse(response.body)
          expect(json.first["name"]).to eq("python") # unpopular tag comes first
        end
      end
    end

    describe "when requesting Turbo Stream format" do
      it "returns turbo stream response" do
        get tags_path, headers: { "Accept" => "text/vnd.turbo-stream.html" }

        expect(response).to have_http_status(:success)
      end
    end
  end
end
