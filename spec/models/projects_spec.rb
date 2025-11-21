require 'rails_helper'

RSpec.describe Project, type: :model do
  describe ".create" do
    let(:user) { FactoryBot.create(:user) }

    describe "when the description is too short" do
      it "is not valid" do
        expect{ Project.create!(description: "A short description", user_id: user.id, name: "Project Name") }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    describe "when there is no description" do
      it "is not valid" do
        expect{ Project.create!(user_id: user.id, name: "Project Name") }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    describe "when the description is longer than 50 characters" do
      it "is valid" do
        expect { Project.create!(description: "A very long description that exceeds the maximum length", user_id: user.id, name: "Project Name") }.to change { Project.count }.by(1)
      end
    end

    describe "when there is no project name" do
      it "is not valid" do
        expect { Project.create!(description: "A very long description that exceeds the maximum length", user_id: user.id) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    describe "when project name is empty" do
      it "is not valid" do
        expect { Project.create!(description: "A very long description that exceeds the maximum length", user_id: user.id, name: "") }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe "#update" do
    let(:user) { FactoryBot.create(:user) }
    let(:project) { FactoryBot.create(:project, user: user) }

    describe "when the description is too short" do
      it "is not valid" do
        expect{ project.update!(description: "A short description", user_id: user.id, name: "Project Name") }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    describe "when the description is longer than 50 characters" do
      it "is valid" do
        expect { project.update!(description: "A very long description that exceeds the maximum length", user_id: user.id, name: "Project Name") }.to change { Project.count }.by(1)
      end
    end
  end
end
