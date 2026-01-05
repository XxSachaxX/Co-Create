require "rails_helper"

RSpec.describe ProjectTag, type: :model do
  describe "associations" do
    let(:project_tag) { FactoryBot.create(:project_tag) }

    it "belongs to tag" do
      expect(project_tag).to respond_to(:tag)
    end

    it "belongs to project" do
      expect(project_tag).to respond_to(:project)
    end
  end

  describe "validations" do
    let!(:existing_project_tag) { FactoryBot.create(:project_tag) }

    describe "when tag_id is not unique for project" do
      let(:duplicate_project_tag) do
        FactoryBot.build(
          :project_tag,
          tag: existing_project_tag.tag,
          project: existing_project_tag.project
        )
      end

      it "is invalid" do
        expect(duplicate_project_tag).not_to be_valid
        expect(duplicate_project_tag.errors[:tag_id]).to include("has already been taken")
      end
    end
  end

  describe "counter cache" do
    let!(:tag) { FactoryBot.create(:tag, projects_count: 0) }
    let!(:project) { FactoryBot.create(:project) }

    describe "when a project_tag is created" do
      it "increments the tag's projects_count" do
        expect {
          FactoryBot.create(:project_tag, tag: tag, project: project)
        }.to change { tag.reload.projects_count }.from(0).to(1)
      end
    end

    describe "when a project_tag is destroyed" do
      let!(:project_tag) { FactoryBot.create(:project_tag, tag: tag, project: project) }

      it "decrements the tag's projects_count" do
        expect {
          project_tag.destroy
        }.to change { tag.reload.projects_count }.from(1).to(0)
      end
    end

    describe "when multiple projects use the same tag" do
      let!(:project2) { FactoryBot.create(:project) }
      let!(:project_tag1) { FactoryBot.create(:project_tag, tag: tag, project: project) }
      let!(:project_tag2) { FactoryBot.create(:project_tag, tag: tag, project: project2) }

      it "maintains accurate count" do
        expect(tag.reload.projects_count).to eq(2)
      end

      describe "when one project_tag is removed" do
        it "decrements count correctly" do
          expect {
            project_tag1.destroy
          }.to change { tag.reload.projects_count }.from(2).to(1)
        end
      end
    end
  end
end
