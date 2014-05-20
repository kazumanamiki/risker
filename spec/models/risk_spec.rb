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
	it { should respond_to(:next_check_date) }
	it { should respond_to(:priority) }

	it { should respond_to(:cost_comments) }
	it { should respond_to(:matter_comments) }
	it { should respond_to(:measure_comments) }
	it { should respond_to(:project) }
	it { should respond_to(:marked_comments) }

	it { should respond_to(:build_marked_comment).with(1).argument }

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

		describe "10時間は" do
			before { risk.check_cycle = 10 }

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

	describe "優先度は" do
		describe "nilは" do
			before { risk.priority = nil }
			it { should be_valid }
		end

		describe "0は" do
			before { risk.priority = 0 }
			it { should_not be_valid }
		end

		describe "5は" do
			before { risk.priority = 5 }
			it { should be_valid }
		end

		describe "10は" do
			before { risk.priority = 10 }
			it { should be_valid }
		end

		describe "-1は" do
			before { risk.priority = -1 }
			it { should_not be_valid }
		end

		describe "11は" do
			before { risk.priority = 11 }
			it { should_not be_valid }
		end
	end

	describe "優先度とコストコメントの関係チェック" do
		let(:priority_risk) { FactoryGirl.create(:risk) }

		describe "コストコメントが含まれていれば優先度が変わる" do
			before do
				priority_risk.priority = nil
				priority_risk.save
			end
			it { expect(priority_risk.priority).to eq nil }

			describe "コストコメントを含めると優先度が変わる" do
				let(:ll_matter_comment) { FactoryGirl.create(:ll_matter_comment, risk_id: priority_risk.id) }
				before { ll_matter_comment.save }
				it { expect(Risk.find(priority_risk.id).priority).to eq 1 }
			end

			describe "優先度は高い方が有効になる" do
				let(:ll_matter_comment) { FactoryGirl.create(:ll_matter_comment, risk_id: priority_risk.id) }
				let(:mm_matter_comment) { FactoryGirl.create(:mm_matter_comment, risk_id: priority_risk.id) }
				before do
					ll_matter_comment.save
					mm_matter_comment.save
				end
				it { expect(Risk.find(priority_risk.id).priority).to eq 4 }

				describe "優先度を消すと一番高い優先度になる" do
					before { mm_matter_comment.destroy }
					it { expect(Risk.find(priority_risk.id).priority).to eq 1 }

					describe "一番高い優先度のチェック" do
						let(:hh_matter_comment) { FactoryGirl.create(:hh_matter_comment, risk_id: priority_risk.id) }
						before { hh_matter_comment.save }
						it { expect(Risk.find(priority_risk.id).priority).to eq 9 }

						describe "全て削除した場合はnilになる" do
							before { priority_risk.cost_comments.each { |obj| obj.destroy } }
							it { expect(Risk.find(priority_risk.id).priority).to eq nil }
						end
					end
				end
			end
		end
	end

	describe "次のチェック日時は" do
		describe "新規作成する際に" do
			let(:risk_check_date) { FactoryGirl.create(:risk) }

			before do
				risk_check_date.check_cycle = 24 * 7 * 4
				risk_check_date.save
			end

			it "チェックサイクル後の時間となる" do
				check_date = risk_check_date.updated_at.since(risk_check_date.check_cycle * 60 * 60)
				expect(risk_check_date.next_check_date.year).to eq check_date.year
				expect(risk_check_date.next_check_date.month).to eq check_date.month
				expect(risk_check_date.next_check_date.day).to eq check_date.day
				expect(risk_check_date.next_check_date.hour).to eq check_date.hour
			end

			describe "更新する際に" do
				before do
					risk_check_date.check_cycle = 5
					risk_check_date.save
				end

				it "チェックサイクル後の時間となる" do
					check_date = risk_check_date.updated_at.since(risk_check_date.check_cycle * 60 * 60)
					expect(risk_check_date.next_check_date.year).to eq check_date.year
					expect(risk_check_date.next_check_date.month).to eq check_date.month
					expect(risk_check_date.next_check_date.day).to eq check_date.day
					expect(risk_check_date.next_check_date.hour).to eq check_date.hour
				end
			end
		end
	end


	describe "対象プロジェクトのリスクを次回チェック日でソート" do
		let(:project) { FactoryGirl.create(:project) }
		let(:risk_check_watch_over) { FactoryGirl.create(:risk) }
		let(:risk_cehck_not_check) { FactoryGirl.create(:risk) }
		let(:risk_check_extinction) { FactoryGirl.create(:risk) }
		let(:risk_check_1) { FactoryGirl.create(:risk) }
		let(:risk_check_2) { FactoryGirl.create(:risk) }
		let(:risk_check_3) { FactoryGirl.create(:risk) }

		before do
			# 監視期限切れ
			risk_check_watch_over.project_id = project.id
			risk_check_watch_over.check_cycle = 1
			risk_check_watch_over.watch_over_date = DateTime.now.yesterday
			risk_check_watch_over.save

			# 監視対象外
			risk_cehck_not_check.project_id = project.id
			risk_cehck_not_check.check_cycle = 0
			risk_cehck_not_check.watch_over_date = DateTime.now.next_month
			risk_cehck_not_check.save

			# クローズ
			risk_check_extinction.project_id = project.id
			risk_check_extinction.check_cycle = 1
			risk_check_extinction.watch_over_date = DateTime.now.next_month
			risk_check_extinction.status = RiskModelHelper::StatusType::EXTINCTION
			risk_check_extinction.save

			# ソート1番目
			risk_check_1.project_id = project.id
			risk_check_1.check_cycle = 1
			risk_check_1.watch_over_date = DateTime.now.next_month
			risk_check_1.save

			# ソート3番目
			risk_check_2.project_id = project.id
			risk_check_2.check_cycle = 100
			risk_check_2.watch_over_date = DateTime.now.next_month
			risk_check_2.save

			# ソート2番目
			risk_check_3.project_id = project.id
			risk_check_3.check_cycle = 50
			risk_check_3.watch_over_date = DateTime.now.next_month
			risk_check_3.save
		end

		it "ヒット件数のチェック" do
			check_date = DateTime.now.since(50)
			risks = Risk.from_projects_check_date_oder(project, datetime: check_date)
			expect(risks.count).to eq 3
		end

		it "ソート順のチェック" do
			check_date = DateTime.now.since(50)
			risks = Risk.from_projects_check_date_oder(project, datetime: check_date)
			expect(risks[0]).to eq risk_check_1
			expect(risks[1]).to eq risk_check_3
			expect(risks[2]).to eq risk_check_2
		end
	end

	describe "対象プロジェクトの日付を超えたリスクが検索できる" do
		let(:project) { FactoryGirl.create(:project) }
		let(:risk_check_date_not_over) { FactoryGirl.create(:risk) }
		let(:risk_check_date_over) { FactoryGirl.create(:risk) }
		let(:risk_cehck_watch_over) { FactoryGirl.create(:risk) }
		let(:risk_cehck_not_check) { FactoryGirl.create(:risk) }
		let(:risk_check_extinction) { FactoryGirl.create(:risk) }

		before do
			# 監視対象リスク
			risk_check_date_not_over.project_id = project.id
			risk_check_date_not_over.check_cycle = 1
			risk_check_date_not_over.watch_over_date = DateTime.now.next_month
			risk_check_date_not_over.save

			# 監視対象リスク
			risk_check_date_over.project_id = project.id
			risk_check_date_over.check_cycle = 10
			risk_check_date_over.watch_over_date = DateTime.now.next_month
			risk_check_date_over.save

			# 監視期間を過ぎたリスク
			risk_cehck_watch_over.project_id = project.id
			risk_cehck_watch_over.check_cycle = 1
			risk_cehck_watch_over.watch_over_date = DateTime.now.yesterday
			risk_cehck_watch_over.save

			# 監視対象外のリスク
			risk_cehck_not_check.project_id = project.id
			risk_cehck_not_check.check_cycle = 0
			risk_cehck_not_check.watch_over_date = DateTime.now.next_month
			risk_cehck_not_check.save

			# 既にクローズされたリスク
			risk_check_extinction.project_id = project.id
			risk_check_extinction.check_cycle = 1
			risk_check_extinction.watch_over_date = DateTime.now.next_month
			risk_check_extinction.status = RiskModelHelper::StatusType::EXTINCTION
			risk_check_extinction.save
		end

		it "0件ヒットのチェック" do
			check_date = DateTime.now.since(60 * 60 * 0)
			risks = Risk.from_projects_primary_check_by(project, datetime: check_date)
			expect(risks.count).to eq 0
		end

		it "1件ヒットのチェック" do
			check_date = DateTime.now.since(60 * 60 * 2)
			risks = Risk.from_projects_primary_check_by(project, datetime: check_date)
			expect(risks.count).to eq 1
		end

		it "2件ヒットのチェック" do
			check_date = DateTime.now.since(60 * 60 * 11)
			risks = Risk.from_projects_primary_check_by(project, datetime: check_date)
			expect(risks.count).to eq 2
		end

		describe "ユーザーの日付を超えたリスクが検索できる" do
			let(:user) { FactoryGirl.create(:user) }

			before do
				project.user_id = user.id
				project.save
			end

			it "1件ヒットのチェック" do
				check_date = DateTime.now.since(60 * 60 * 2)
				risks = Risk.from_users_primary_check_by(user, datetime: check_date)
				expect(risks.count).to eq 1
			end

			describe "複数のプロジェクトも検索できる" do
				let(:project2) { FactoryGirl.create(:project) }
				let(:risk_project2) { FactoryGirl.create(:risk) }

				before do
					project2.user_id = user.id
					project2.save

					risk_project2.project_id = project2.id
					risk_project2.check_cycle = 1
					risk_project2.watch_over_date = DateTime.now.next_month
					risk_project2.save
				end

				it "2件ヒットのチェック" do
					check_date = DateTime.now.since(60 * 60 * 2)
					risks = Risk.from_users_primary_check_by(user, datetime: check_date)
					expect(risks.count).to eq 2
				end
			end
		end
	end

	describe "コストコメントを作成できる" do
		let(:cost_comment) { risk.cost_comments.build }
		it { expect(risk.id).to eq cost_comment.risk_id }

		describe "コストコメント取得のテスト" do
			describe "MATTERコメントを取得できる" do

				let (:test_cost_comment) { FactoryGirl.create(:cost_comment) }

				before do
					test_cost_comment.risk_id = risk.id
					test_cost_comment.cost_type = CostCommentModelHelper::CostCommentType::MATTER
				end

				it { expect { test_cost_comment.save }.to change(risk.matter_comments, :count).by(1) }
			end

			describe "MEASUREコメントを取得できる" do

				let (:test_cost_comment) { FactoryGirl.create(:cost_comment) }

				before do
					test_cost_comment.risk_id = risk.id
					test_cost_comment.cost_type = CostCommentModelHelper::CostCommentType::MEASURE
				end

				it { expect { test_cost_comment.save }.to change(risk.measure_comments, :count).by(1) }
			end

			describe "全てのコストコメントを取得できる" do

				let (:test_cost_comment) { FactoryGirl.create(:cost_comment) }

				before do
					test_cost_comment.risk_id = risk.id
					test_cost_comment.cost_type = 3
				end

				it { expect { test_cost_comment.save }.to change(risk.cost_comments, :count).by(1) }
			end
		end
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
