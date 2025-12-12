require 'rails_helper'

RSpec.describe Project, type: :model do
  describe "requested_membership?" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:project) { FactoryBot.create(:project) }
    let!(:owner_membership) { FactoryBot.create(:project_membership, project: project, user: user, status: "active", role: "owner") }

    describe "when the user has a pending membership request" do
      let!(:wannabe_collaborator) { FactoryBot.create(:user) }
      let!(:membership) { FactoryBot.create(:project_membership, project: project, user: wannabe_collaborator, status: "pending", role: "member") }


      it "returns true if the user has a pending membership request" do
        expect(project.requested_membership?(wannabe_collaborator)).to be true
      end
    end

    describe "when the user does not have a pending membership request" do
      it "returns false if the user does not have a pending membership request" do
        expect(project.requested_membership?(user)).to be false
      end
    end
  end
end
