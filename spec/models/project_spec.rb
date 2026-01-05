require 'rails_helper'

RSpec.describe Project, type: :model do
  describe "requested_membership?" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:project) { FactoryBot.create(:project) }
    let!(:owner_membership) { FactoryBot.create(:project_membership, project: project, user: user, status: ProjectMembership::ACTIVE, role: ProjectMembership::OWNER) }

    describe "when the user has a pending membership request" do
      let!(:wannabe_collaborator) { FactoryBot.create(:user) }
      let!(:membership_request) { FactoryBot.create(:project_membership_request, project: project, user: wannabe_collaborator) }


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

  describe "collaborator?" do
    let!(:owner) { FactoryBot.create(:user) }
    let!(:project) { FactoryBot.create(:project) }
    let!(:owner_membership) { FactoryBot.create(:project_membership, project: project, user: owner, status: ProjectMembership::ACTIVE, role: ProjectMembership::OWNER) }

    describe "when the user has not project membership" do
      let!(:user) { FactoryBot.create(:user) }

      it "returns false" do
        expect(project.collaborator?(user)).to be false
      end
    end

    describe "when the user has a pending membership request" do
      let!(:user) { FactoryBot.create(:user) }
      let!(:pending_membership) { FactoryBot.create(:project_membership_request, project: project, user: user, status: ProjectMembershipRequest::PENDING) }

      it "returns false" do
        expect(project.collaborator?(user)).to be false
      end
    end

    describe "when the user has a revoked project membership" do
      let!(:user) { FactoryBot.create(:user) }
      let!(:project) { FactoryBot.create(:project) }
      let!(:revoked_membership) { FactoryBot.create(:project_membership, project: project, user: user, status: ProjectMembership::REVOKED, role: ProjectMembership::MEMBER) }

      it "returns false" do
        expect(project.collaborator?(user)).to be false
      end
    end

    describe "when the user has an active project membership" do
      let!(:user) { FactoryBot.create(:user) }
      let!(:project) { FactoryBot.create(:project) }
      let!(:active_membership) { FactoryBot.create(:project_membership, project: project, user: user, status: ProjectMembership::ACTIVE, role: ProjectMembership::MEMBER) }

      it "returns true" do
        expect(project.collaborator?(user)).to be true
      end
    end

    describe "when the user has both an active and revoked project membership" do
      let!(:user) { FactoryBot.create(:user) }
      let!(:project) { FactoryBot.create(:project) }
      let!(:active_membership) { FactoryBot.create(:project_membership, project: project, user: user, status: ProjectMembership::ACTIVE, role: ProjectMembership::MEMBER) }

      describe "when the user has both an active and revoked project membership" do
        describe "when the active membership is newer than the revoked one" do
          let!(:active_membership) { FactoryBot.create(:project_membership, project: project, user: user, status: ProjectMembership::ACTIVE, role: ProjectMembership::MEMBER) }
          let!(:revoked_membership) { FactoryBot.create(:project_membership, project: project, user: user, status: ProjectMembership::REVOKED, role: ProjectMembership::MEMBER, created_at: 2.days.ago) }

          it "returns true" do
            expect(project.collaborator?(user)).to be true
          end
        end
      end
    end
  end

  describe "associations" do
    let(:project) { FactoryBot.create(:project) }

    it "has many project_tags" do
      expect(project).to respond_to(:project_tags)
    end

    it "has many tags through project_tags" do
      expect(project).to respond_to(:tags)
    end
  end

  describe "#tag_list" do
    describe "when project has tags" do
      let!(:project) { FactoryBot.create(:project, tag_list: [ "rails", "saas" ]) }

      it "returns an array of tag names" do
        expect(project.tag_list).to match_array([ "rails", "saas" ])
      end
    end

    describe "when project has no tags" do
      let(:project) { FactoryBot.create(:project) }

      it "returns an empty array" do
        expect(project.tag_list).to eq([])
      end
    end
  end

  describe "#tag_list=" do
    describe "when assigning new tag names" do
      let(:project) { FactoryBot.create(:project, tag_list: [ "rails", "saas" ]) }

      it "creates new tags and assigns them to the project" do
        expect(project.tags.pluck(:name)).to match_array([ "rails", "saas" ])
      end
    end

    describe "when tags already exist" do
      let!(:existing_tag) { FactoryBot.create(:tag, name: "rails") }
      let(:project) { FactoryBot.create(:project, tag_list: [ "rails", "saas" ]) }

      it "reuses existing tags instead of creating duplicates" do
        expect(Tag.where(name: "rails").count).to eq(1)
        expect(project.tags).to include(existing_tag)
      end
    end

    describe "when tag names need normalization" do
      describe "when uppercase" do
        let(:project) { FactoryBot.create(:project, tag_list: [ "Rails", "SAAS" ]) }

        it "normalizes to lowercase" do
          expect(project.tags.pluck(:name)).to match_array([ "rails", "saas" ])
        end
      end

      describe "when whitespace present" do
        let(:project) { FactoryBot.create(:project, tag_list: [ "  rails  ", "  saas  " ]) }

        it "strips whitespace" do
          expect(project.tags.pluck(:name)).to match_array([ "rails", "saas" ])
        end
      end

      describe "when spaces in name" do
        let(:project) { FactoryBot.create(:project, tag_list: [ "Ruby on Rails", "Web Development" ]) }

        it "converts spaces to hyphens" do
          expect(project.tags.pluck(:name)).to match_array([ "ruby-on-rails", "web-development" ])
        end
      end
    end

    describe "when duplicate tag names are provided" do
      let(:project) { FactoryBot.create(:project, tag_list: [ "rails", "Rails", "rails", "RAILS" ]) }

      it "removes duplicates and assigns tag only once" do
        expect(project.tags.count).to eq(1)
        expect(project.tags.first.name).to eq("rails")
      end
    end

    describe "when assigning empty or nil values" do
      describe "when nil" do
        let(:project) { FactoryBot.create(:project, tag_list: nil) }

        it "handles gracefully" do
          expect(project.tags).to be_empty
        end
      end

      describe "when blank strings present" do
        let(:project) { FactoryBot.create(:project, tag_list: [ "rails", "", "  ", "saas" ]) }

        it "filters out blank strings" do
          expect(project.tags.pluck(:name)).to match_array([ "rails", "saas" ])
        end
      end
    end

    describe "when exceeding maximum tag limit" do
      let(:project) { FactoryBot.build(:project, tag_list: (1..11).map { |i| "tag#{i}" }) }

      it "is invalid" do
        expect(project).not_to be_valid
        expect(project.errors[:tag_list]).to include("maximum 10 tags allowed")
      end
    end

    describe "when exactly at tag limit" do
      let(:project) { FactoryBot.build(:project, tag_list: (1..10).map { |i| "tag#{i}" }) }

      it "is valid" do
        expect(project).to be_valid
      end
    end

    describe "when replacing existing tags" do
      let!(:project) { FactoryBot.create(:project, tag_list: [ "rails", "ruby" ]) }

      it "replaces old tags with new ones" do
        project.tag_list = [ "javascript", "react" ]
        project.save!

        expect(project.tags.pluck(:name)).to match_array([ "javascript", "react" ])
        expect(project.tags.pluck(:name)).not_to include("rails", "ruby")
      end
    end
  end

  describe "#tag_names" do
    describe "when project has tags" do
      let!(:project) { FactoryBot.create(:project, tag_list: [ "rails", "saas", "education" ]) }

      it "returns comma-separated string of tag names" do
        expect(project.tag_names).to eq("rails, saas, education")
      end
    end

    describe "when project has no tags" do
      let(:project) { FactoryBot.create(:project) }

      it "returns empty string" do
        expect(project.tag_names).to eq("")
      end
    end
  end

  describe "#tag_names=" do
    describe "when assigning comma-separated string" do
      let(:project) { FactoryBot.create(:project, tag_names: "rails, saas, education") }

      it "parses and assigns tags" do
        expect(project.tags.pluck(:name)).to match_array([ "rails", "saas", "education" ])
      end
    end

    describe "when string has irregular spacing" do
      let(:project) { FactoryBot.create(:project, tag_names: "rails,  saas  , education") }

      it "handles extra spaces gracefully" do
        expect(project.tags.pluck(:name)).to match_array([ "rails", "saas", "education" ])
      end
    end

    describe "when string is blank" do
      let(:project) { FactoryBot.create(:project, tag_names: "") }

      it "does not assign any tags" do
        expect(project.tags).to be_empty
      end
    end

    describe "when string has trailing/leading commas" do
      let(:project) { FactoryBot.create(:project, tag_names: ",rails, saas,") }

      it "ignores empty entries" do
        expect(project.tags.pluck(:name)).to match_array([ "rails", "saas" ])
      end
    end
  end

  describe "scopes" do
    let!(:rails_project) { FactoryBot.create(:project, tag_list: [ "rails", "backend" ]) }
    let!(:js_project) { FactoryBot.create(:project, tag_list: [ "javascript", "frontend" ]) }
    let!(:fullstack_project) { FactoryBot.create(:project, tag_list: [ "rails", "javascript" ]) }

    describe ".with_any_tags" do
      describe "when filtering by a single tag" do
        it "returns projects that have that tag" do
          results = Project.with_any_tags([ "rails" ])
          expect(results).to include(rails_project, fullstack_project)
          expect(results).not_to include(js_project)
        end
      end

      describe "when filtering by multiple tags (OR logic)" do
        it "returns projects that have any of the specified tags" do
          results = Project.with_any_tags([ "rails", "javascript" ])
          expect(results).to include(rails_project, js_project, fullstack_project)
        end
      end

      describe "when filtering by tag that doesn't exist" do
        it "returns no projects" do
          results = Project.with_any_tags([ "python" ])
          expect(results).to be_empty
        end
      end

      describe "when tags parameter is blank" do
        it "returns all projects" do
          expect(Project.with_any_tags([]).to_a).to match_array(Project.all.to_a)
          expect(Project.with_any_tags(nil).to_a).to match_array(Project.all.to_a)
        end
      end

      describe "when project has multiple matching tags" do
        it "returns project only once (no duplicates)" do
          results = Project.with_any_tags([ "rails", "backend" ])
          expect(results.to_a.count(rails_project)).to eq(1)
        end
      end
    end

    describe ".with_all_tags" do
      describe "when filtering by multiple tags (AND logic)" do
        it "returns only projects that have all specified tags" do
          results = Project.with_all_tags([ "rails", "javascript" ])
          expect(results).to eq([ fullstack_project ])
        end
      end

      describe "when filtering by single tag" do
        it "returns projects that have that tag" do
          results = Project.with_all_tags([ "rails" ])
          expect(results).to include(rails_project, fullstack_project)
          expect(results).not_to include(js_project)
        end
      end

      describe "when no project has all specified tags" do
        it "returns empty result" do
          results = Project.with_all_tags([ "rails", "python" ])
          expect(results).to be_empty
        end
      end

      describe "when tags parameter is blank" do
        it "returns all projects" do
          expect(Project.with_all_tags([]).to_a).to match_array(Project.all.to_a)
          expect(Project.with_all_tags(nil).to_a).to match_array(Project.all.to_a)
        end
      end
    end
  end
end
