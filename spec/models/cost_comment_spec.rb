require 'spec_helper'

describe CostComment do
	let(:cost_comment) { FactoryGirl.create(:cost_comment) }

	subject { cost_comment }

	# メンバチェック
	it { should respond_to(:cost_type) }
	it { should respond_to(:comment) }
	it { should respond_to(:cost_memo) }
	it { should respond_to(:risk_id) }
	it { should respond_to(:probability) }
	it { should respond_to(:influence) }
	it { should respond_to(:priority) }

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

	describe "発生率は" do
		describe "nilは" do
			before { cost_comment.probability = nil }
			it { should be_valid }
		end
		describe "0は" do
			before { cost_comment.probability = 0 }
			it { should_not be_valid }
		end
		describe "低は" do
			before { cost_comment.probability = CostCommentModelHelper::ProbabilityType::LOW }
			it { should be_valid }
		end
		describe "中は" do
			before { cost_comment.probability = CostCommentModelHelper::ProbabilityType::MIDDLE }
			it { should be_valid }
		end
		describe "高は" do
			before { cost_comment.probability = CostCommentModelHelper::ProbabilityType::HIGH }
			it { should be_valid }
		end
		describe "4は" do
			before { cost_comment.probability = 4 }
			it { should_not be_valid }
		end
	end

	describe "影響は" do
		describe "nilは" do
			before { cost_comment.influence = nil }
			it { should be_valid }
		end
		describe "0は" do
			before { cost_comment.influence = 0 }
			it { should_not be_valid }
		end
		describe "低は" do
			before { cost_comment.influence = CostCommentModelHelper::InfluenceType::LOW }
			it { should be_valid }
		end
		describe "中は" do
			before { cost_comment.influence = CostCommentModelHelper::InfluenceType::MIDDLE }
			it { should be_valid }
		end
		describe "高は" do
			before { cost_comment.influence = CostCommentModelHelper::InfluenceType::HIGH }
			it { should be_valid }
		end
		describe "4は" do
			before { cost_comment.influence = 4 }
			it { should_not be_valid }
		end
	end

	describe "優先度は" do
		describe "nilは" do
			before { cost_comment.priority = nil }
			it { should be_valid }
		end
		describe "0は" do
			before { cost_comment.priority = 0 }
			it { should_not be_valid }
		end
		describe "1は" do
			before { cost_comment.priority = 1 }
			it { should be_valid }
		end
		describe "5は" do
			before { cost_comment.priority = 5 }
			it { should be_valid }
		end
		describe "10は" do
			before { cost_comment.priority = 10 }
			it { should be_valid }
		end
		describe "11は" do
			before { cost_comment.priority = 11 }
			it { should_not be_valid }
		end
	end

	describe "優先度は発生率と影響で決定される" do
		let(:priority_comment) { FactoryGirl.create(:cost_comment) }
		before { priority_comment.priority = nil }

		describe "発生率と影響の値が反映される" do
			before do
				priority_comment.probability = CostCommentModelHelper::ProbabilityType::HIGH
				priority_comment.influence = CostCommentModelHelper::InfluenceType::HIGH
				priority_comment.save
			end
			it { expect(priority_comment.priority).to eq 9 }

			describe "発生率がnilの場合は低として扱われる" do
				before do
					priority_comment.probability = nil
					priority_comment.influence = CostCommentModelHelper::InfluenceType::HIGH
					priority_comment.save
				end
				it { expect(priority_comment.priority).to eq 3 }
			end

			describe "影響がnilの場合は低として扱われる" do
				before do
					priority_comment.probability = CostCommentModelHelper::ProbabilityType::MIDDLE
					priority_comment.influence = nil
					priority_comment.save
				end
				it { expect(priority_comment.priority).to eq 2 }
			end

			describe "両方ともnilの場合はnilとして扱われる" do
				before do
					priority_comment.probability = nil
					priority_comment.influence = nil
					priority_comment.save
				end
				it { expect(priority_comment.priority).to eq nil }
			end
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
		it { expect(comment_user.comments.first.comment).to eq comment.comment }
		it { expect(cost_comment.marked_comments.first.comment).to eq comment.comment }

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
