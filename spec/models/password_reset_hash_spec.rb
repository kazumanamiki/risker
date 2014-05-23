require 'spec_helper'

describe PasswordResetHash do
	let(:reset_hash) { FactoryGirl.create(:password_reset_hash) }

	subject { reset_hash }

	# メンバチェック
	it { should respond_to(:user_id) }
	it { should respond_to(:hash_pass) }
	it { should respond_to(:enable_flag) }

	it { should respond_to(:user) }

	it { should be_valid }

	describe "ハッシュ値が生成できる" do
		let(:user) { FactoryGirl.create(:user) }
		before { user.save }
		it { expect(PasswordResetHash.generate_reset_hash(user)).not_to eq nil }

		describe "ハッシュ値からユーザーが参照できる" do
			let(:hash) { PasswordResetHash.generate_reset_hash(user) }
			it { expect(PasswordResetHash.where(hash_pass: hash).first.user).to eq user }

			describe "ハッシュ値の有効性チェック" do
				let(:reset_hash_1) { PasswordResetHash.where(hash_pass: hash).first }
				it { expect(reset_hash_1.valid_hash?(Time.zone.now + 1.hour)).to be_false }

				describe "ハッシュ値は一時間前は有効" do
					it { expect(reset_hash_1.valid_hash?(Time.zone.now + 1.hour - 1.minute)).to be_true }
				end

				describe "ハッシュ値は一時間後は無効" do
					it { expect(reset_hash_1.valid_hash?(Time.zone.now + 1.hour)).to be_false }
				end
			end
		end
	end

	describe "有効フラグの動作確認" do
		let(:user) { FactoryGirl.create(:user) }
		before do
			user.save
			PasswordResetHash.generate_reset_hash(user)
		end

		it do
			reset_hash_1 = PasswordResetHash.where(user_id: user.id).first
			expect(reset_hash_1.valid_hash?(Time.zone.now)).to be_true
		end

		describe "有効フラグを無効にした場合" do
			it do
				PasswordResetHash.disable_reset_hash(user)
				reset_hash_1 = PasswordResetHash.where(user_id: user.id).first
				expect(reset_hash_1.valid_hash?(Time.zone.now)).to be_false
			end

			describe "再発行した場合" do
				it do
					hash = PasswordResetHash.generate_reset_hash(user)
					expect(PasswordResetHash.where(hash_pass: hash).first.valid_hash?(Time.zone.now)).to be_true
				end
			end
		end
	end

	describe "ユーザー以上に生成されない" do
		let(:user1) { FactoryGirl.create(:user) }
		let(:user2) { FactoryGirl.create(:user) }

		before do
			user1.save
			user2.save
		end

		it { expect {
				PasswordResetHash.generate_reset_hash(user1)
				PasswordResetHash.generate_reset_hash(user2)
				PasswordResetHash.generate_reset_hash(user1)
				PasswordResetHash.generate_reset_hash(user2)
			}.to change(PasswordResetHash, :count).by(2)
		}
	end
end
