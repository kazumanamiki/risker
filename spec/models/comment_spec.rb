require 'spec_helper'

describe Comment do
	let(:comment) { FactoryGirl.create(:comment) }

	subject { comment }

	# メンバチェック
	it { should respond_to(:user_id) }
	it { should respond_to(:comment) }
	it { should respond_to(:id_type) }
	it { should respond_to(:target_id) }

	it { should be_valid }

	describe "ユーザーIDは" do
		describe "空は" do
			before { comment.user_id = nil }

			it { should_not be_valid }
		end
	end

	describe "コメントは" do
		describe "空は" do
			before { comment.comment = "" }

			it { should_not be_valid }
		end

		describe "301文字は" do
			before { comment.comment = "a" * 301 }

			it { should_not be_valid }
		end
	end

	describe "id_typeは" do
		describe "nilは" do
			before { comment.id_type = nil }

			it { should_not be_valid }
		end
	end

	describe "target_idは" do
		describe "nilは" do
			before { comment.target_id = nil }

			it { should_not be_valid }
		end
	end

	describe "コメントが対象のテーブルに関連するかのテスト" do
		let(:user) { FactoryGirl.create(:user) }
		let(:project) { FactoryGirl.create(:project) }
		let(:risk) { FactoryGirl.create(:risk) }
		let(:cost_comment) { FactoryGirl.create(:cost_comment)}

		let(:comment_user) { FactoryGirl.create(:user) }

		let(:users_comment) { user.build_marked_comment(comment_user) }
		let(:projects_comment) { project.build_marked_comment(comment_user) }
		let(:risks_comment) { risk.build_marked_comment(comment_user) }
		let(:cost_comments_comment) { cost_comment.build_marked_comment(comment_user) }

		before do
			users_comment.comment = "ユーザーへのコメント"
			projects_comment.comment = "プロジェクトへのコメント"
			risks_comment.comment = "リスクへのコメント"
			cost_comments_comment.comment = "コストコメントへのコメント"

		end

		describe "ユーザーへのコメント追加" do
			it { expect { users_comment.save }.to change(user.marked_comments, :count).by(1) }
			it { expect { projects_comment.save }.to change(user.marked_comments, :count).by(0) }
			it { expect { risks_comment.save }.to change(user.marked_comments, :count).by(0) }
			it { expect { cost_comments_comment.save }.to change(user.marked_comments, :count).by(0) }
		end

		describe "プロジェクトへのコメント追加" do
			it { expect { users_comment.save }.to change(project.marked_comments, :count).by(0) }
			it { expect { projects_comment.save }.to change(project.marked_comments, :count).by(1) }
			it { expect { risks_comment.save }.to change(project.marked_comments, :count).by(0) }
			it { expect { cost_comments_comment.save }.to change(project.marked_comments, :count).by(0) }
		end

		describe "リスクへのコメント追加" do
			it { expect { users_comment.save }.to change(risk.marked_comments, :count).by(0) }
			it { expect { projects_comment.save }.to change(risk.marked_comments, :count).by(0) }
			it { expect { risks_comment.save }.to change(risk.marked_comments, :count).by(1) }
			it { expect { cost_comments_comment.save }.to change(risk.marked_comments, :count).by(0) }
		end

		describe "コストコメントへのコメント" do
			it { expect { users_comment.save }.to change(cost_comment.marked_comments, :count).by(0) }
			it { expect { projects_comment.save }.to change(cost_comment.marked_comments, :count).by(0) }
			it { expect { risks_comment.save }.to change(cost_comment.marked_comments, :count).by(0) }
			it { expect { cost_comments_comment.save }.to change(cost_comment.marked_comments, :count).by(1) }
		end

		describe "全てへコメントでコメントしたユーザーのコメント数が正しいか" do
			it { expect do
				users_comment.save
				projects_comment.save
				risks_comment.save
				cost_comments_comment.save
			end.to change(comment_user.comments, :count).by(4) }
		end
	end

end
