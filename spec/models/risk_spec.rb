require 'spec_helper'

describe Risk do
	let(:risk) { FactoryGirl.create(:risk) }

	subject { risk }

	# メンバチェック
	it { should respond_to(:title) }
	it { should respond_to(:details) }
	it { should respond_to(:status) }
	it { should respond_to(:check_cycle) }
	it { should respond_to(:watch_over_date) }
	it { should respond_to(:project_id) }

	it { should respond_to(:cost_comments) }
	it { should respond_to(:build_marked_comment).with(1).argument }
	it { should respond_to(:marked_comments) }
	it { should respond_to(:project) }

	it { should be_valid }

	describe "プロジェクトIDが含まれていないとけない" do
		before { risk.project_id = nil }

		it { should_not be_valid }
	end

	describe "タイトルは" do
		describe "空は" do
			before { risk.title = "" }

			it { should_not be_valid }
		end

		describe "31文字以上は" do
			before { risk.title = "a" * 31 }

			it { should_not be_valid }
		end
	end

	describe "詳細は" do
		describe "空は" do
			before { risk.details = "" }

			it { should be_valid }
		end

		describe "301文字以上は" do
			before { risk.details = "a" * 301 }

			it { should_not be_valid }
		end
	end

	#describe "ステータスは" do
	#
	#end

	describe "チェックサイクルは" do
		describe "nilは" do
			before { risk.check_cycle = nil }

			it { should_not be_valid }
		end

		describe "0(監視しない)は" do
			before { risk.check_cycle = 0 }

			it { should be_valid }
		end

		describe "4週間以上は" do
			before { risk.check_cycle = 24 * 7 * 4 + 1 }

			it { should_not be_valid }
		end
	end

	describe "監視終了日時は" do
		describe "nilは" do
			before { risk.watch_over_date = nil}

			it { should_not be_valid }
		end
	end

	describe "コストコメントを作成できる" do
		let(:cost_comment) { risk.cost_comments.build }
		it { expect(risk.id).to eq cost_comment.risk_id }
	end

	describe "コメントを作成できる" do
		let(:comment_user) { FactoryGirl.create(:user) }
		let(:comment) { risk.build_marked_comment(comment_user) }

		before do
			comment.comment = "コメントを書く"
			comment.save
		end

		it { expect(comment.id_type).to eq CommentModelHelper::CommentType::RISK }
		it { expect(comment.target_id).to eq risk.id }
		it { expect(comment_user.comments.first.comment).to eq comment.comment}
		it { expect(risk.marked_comments.first.comment).to eq comment.comment}

		describe "二つ目のコメントを作る" do
			let(:comment_user2) { FactoryGirl.create(:user) }
			let(:comment2) { risk.build_marked_comment(comment_user2) }

			before do
				comment2.comment = "コメント2"
			end

			it { expect { comment2.save }.to change(risk.marked_comments, :count).by(1) }
			it { expect { comment2.save }.to change(comment_user2.comments, :count).by(1) }
			it { expect { comment2.save }.to change(comment_user.comments, :count).by(0) }
		end
	end
end
