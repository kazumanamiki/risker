require 'spec_helper'

describe Project do

	let(:project) { FactoryGirl.create(:project) }

	subject { project }

	# メンバチェック
	it { should respond_to(:name) }
	it { should respond_to(:user_id) }

	it { should respond_to(:risks) }
	it { should respond_to(:build_marked_comment).with(1).argument }
	it { should respond_to(:marked_comments) }
	it { should respond_to(:user) }

	it { should be_valid }


	describe "ユーザーIDが含まれていないといけない" do
		before { project.user_id = nil }

		it { should_not be_valid }
	end

	describe "名前は" do

		describe "空は" do
			before { project.name = "" }

			it { should_not be_valid }
		end

		describe "31文字以上は" do
			before { project.name = "a" * 31 }

			it { should_not be_valid }
		end
	end

	describe "リスクを作成できる" do
		let(:risk) { project.risks.build }
		it { expect(project.id).to eq risk.project_id }
	end

	describe "コメントを作成できる" do
		let(:comment_user) { FactoryGirl.create(:user) }
		let(:comment) { project.build_marked_comment(comment_user) }

		before do
			comment.comment = "コメントを書く"
			comment.save
		end

		it { expect(comment.id_type).to eq CommentModelHelper::CommentType::PROJECT }
		it { expect(comment.target_id).to eq project.id }
		it { expect(comment_user.comments.first.comment).to eq comment.comment}
		it { expect(project.marked_comments.first.comment).to eq comment.comment}

		describe "二つ目のコメントを作る" do
			let(:comment_user2) { FactoryGirl.create(:user) }
			let(:comment2) { project.build_marked_comment(comment_user2) }

			before do
				comment2.comment = "コメント2"
			end

			it { expect { comment2.save }.to change(project.marked_comments, :count).by(1) }
			it { expect { comment2.save }.to change(comment_user2.comments, :count).by(1) }
			it { expect { comment2.save }.to change(comment_user.comments, :count).by(0) }
		end
	end
end
