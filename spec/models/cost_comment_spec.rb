require 'spec_helper'

describe CostComment do
	let(:cost_comment) { FactoryGirl.create(:cost_comment) }

	subject { cost_comment }

	# メンバチェック
	it { should respond_to(:type) }
	it { should respond_to(:comment) }
	it { should respond_to(:cost_memo) }
	it { should respond_to(:risk_id) }

	it { should respond_to(:build_marked_comment).with(1).argument }
	it { should respond_to(:marked_comments) }
	it { should respond_to(:risk) }

	it { should be_valid }

	describe "リスクIDが含まれていないとけない" do
		before { cost_comment.risk_id = nil }

		it { should_not be_valid }
	end

	#describe "種別は"
	#
	#end

	describe "コメントは" do
		describe "0文字は" do
			before { cost_comment.comment = "" }

			it { should_not be_valid }
		end

		describe "301文字以上は" do
			before { cost_comment.comment = "a" * 301 }

			it { should_not be_valid }
		end
	end

	describe "コストは" do
		describe "0文字は" do
			before { cost_comment.cost_memo = "" }

			it { should be_valid }
		end

		describe "301文字以上は" do
			before { cost_comment.cost_memo = "a" * 301 }

			it { should_not be_valid }
		end
	end

	describe "コメントを作成できる" do
		let(:comment_user) { FactoryGirl.create(:user) }
		let(:comment) { cost_comment.build_marked_comment(comment_user) }

		before do
			comment.comment = "コメントを書く"
			comment.save
		end

		it { expect(comment.id_type).to eq CommentModelHelper::CommentType::COST_COMMENT }
		it { expect(comment.target_id).to eq cost_comment.id }
		it { expect(comment_user.comments.first.comment).to eq comment.comment}
		it { expect(cost_comment.marked_comments.first.comment).to eq comment.comment}

		describe "二つ目のコメントを作る" do
			let(:comment_user2) { FactoryGirl.create(:user) }
			let(:comment2) { cost_comment.build_marked_comment(comment_user2) }

			before do
				comment2.comment = "コメント2"
			end

			it { expect { comment2.save }.to change(cost_comment.marked_comments, :count).by(1) }
			it { expect { comment2.save }.to change(comment_user2.comments, :count).by(1) }
			it { expect { comment2.save }.to change(comment_user.comments, :count).by(0) }
		end
	end
end
