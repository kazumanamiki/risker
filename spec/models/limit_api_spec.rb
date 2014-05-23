require 'spec_helper'

describe LimitApi do
	let(:limit_api) { FactoryGirl.create(:limit_api) }

	subject { limit_api }

	# メンバチェック
	it { should respond_to(:api) }
	it { should respond_to(:counter) }
	it { should respond_to(:counted_at) }

	it { should be_valid }

	describe "クラスメソッドでAPI使用回数をチェック(reset_email)" do

		it "初回実行" do
			not_api = LimitApi.where(api: "reset_email").first
			expect(not_api).to eq nil

			LimitApi.use_api?(:reset_email)

			be_api = LimitApi.where(api: "reset_email").first
			expect(be_api).not_to eq nil
		end

		describe "二回目のAPI使用をチェック" do
			it { expect { LimitApi.use_api?(:reset_email) }.to change(LimitApi.where(api: "reset_email"), :count).by(1) }
		end

		describe "回数制限まで使用" do
			it do
				12.times do |index|
					expect(LimitApi.use_api?(:reset_email)).to be_true
					expect(LimitApi.where(api: "reset_email").first.counter).to eq index + 1
				end
			end
		end

		describe "回数オーバーでエラー" do
			it do
				12.times { LimitApi.use_api?(:reset_email) }
				expect(LimitApi.use_api?(:reset_email)).to be_false
			end
		end
	end
end
