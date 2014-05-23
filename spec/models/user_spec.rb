require 'spec_helper'

describe User do

	let(:user) { FactoryGirl.create(:user) }

	subject { user }

	# メンバチェック
	it { should respond_to(:nickname) }
	it { should respond_to(:password_digest) }
	it { should respond_to(:password) }
	it { should respond_to(:password_confirmation) }
	it { should respond_to(:email) }

	it { should respond_to(:projects) }
	it { should respond_to(:comments) }
	it { should respond_to(:marked_comments) }

	it { should respond_to(:build_marked_comment).with(1).argument }

	it { should be_valid }

	describe "ニックネームの" do
		describe "空は" do
			before { user.nickname = "" }
			it { should_not be_valid }
		end

		describe "3文字以下は" do
			before { user.nickname = "a" * 3 }
			it { should_not be_valid }
		end

		describe "31文字以上は" do
			before { user.nickname = "a" * 31 }
			it { should_not be_valid }
		end

		describe "重複は登録できない" do
			before do
				@user_with_same_nickname = User.new
				@user_with_same_nickname.nickname = user.nickname.upcase
				@user_with_same_nickname.password = "foobar"
				@user_with_same_nickname.password_confirmation = "foobar"
			end

			it { expect(@user_with_same_nickname).not_to be_valid }
		end
	end

	describe "パスワード" do
		describe "異なっている場合は" do
			before do
				user.password = "abcdef"
				user.password_confirmation = "foobar"
			end

			it { should_not be_valid }
		end

		describe "5文字以下は" do
			before { user.password = user.password_confirmation = "a" * 5 }

			it { should_not be_valid }
		end
	end

	describe "emailの" do
		describe "nilは" do
			before { user.email = nil }
			it { should_not be_valid }
		end

		describe "空は" do
			before { user.email = "" }
			it { should_not be_valid }
		end

		describe "メールアドレスでない文字列は" do
			describe "英字だけ" do
				before { user.email = "aaaaa" }
				it { should_not be_valid }
			end

			describe "日本語が含まれている" do
				before { user.email = "てすと@risker.info" }
				it { should_not be_valid }
			end

			describe "ドメインが不正" do
				before { user.email = "test@risker" }
				it { should_not be_valid }
			end
		end

		describe "正しいメールアドレスは" do
			before { user.email = "test.user@risker.info" }
			it { should be_valid }
		end

		describe "大文字は小文字になる" do
			before do
				user.email = "Test.User@Risker.Info"
				user.save
			end
			it { expect(user.email).to eq "test.user@risker.info" }
		end

		describe "重複しての登録はできない" do
			let(:dup_user) { FactoryGirl.create(:user) }
			before do
				dup_user.email = "test.user@risker.info"
				dup_user.password = "foobar"
				dup_user.password_confirmation = "foobar"
				dup_user.save
				user.email = dup_user.email
			end
			it { should_not be_valid }
		end
	end

	describe "プロジェクトを作成できる" do
		let(:project) do
			user.projects.build(name: "Users Project")
		end
		subject { project }

		it { should be_valid }
		it { expect(user.id).to eq project.user_id }
	end

	describe "コメントを作成できる" do
		let(:comment_user) { FactoryGirl.create(:user) }
		let(:comment) { user.build_marked_comment(comment_user) }

		before do
			comment.comment = "コメントを書く"
			comment.save
		end

		it { expect(comment.id_type).to eq CommentModelHelper::CommentType::USER }
		it { expect(comment.target_id).to eq user.id }
		it { expect(comment_user.comments.first.comment).to eq comment.comment}
		it { expect(user.marked_comments.first.comment).to eq comment.comment}

		describe "二つ目のコメントを作る" do
			let(:comment_user2) { FactoryGirl.create(:user) }
			let(:comment2) { user.build_marked_comment(comment_user2) }

			before do
				comment2.comment = "コメント2"
			end

			it { expect { comment2.save }.to change(user.marked_comments, :count).by(1) }
			it { expect { comment2.save }.to change(comment_user2.comments, :count).by(1) }
			it { expect { comment2.save }.to change(comment_user.comments, :count).by(0) }
		end
	end
end
