FactoryGirl.define do
	factory :user do
		sequence(:nickname) { |n| "User#{n}" }
		password "foobar"
		password_confirmation "foobar"
	end

	factory :project do
		sequence(:name) { |n| "Project#{n}" }
		sequence(:user_id) { |n| n }
	end

	factory :risk do
		sequence(:title) { |n| "Risk#{n}" }
		sequence(:details) { |n| "Risk detail #{n}" }
		status 0
		check_cycle 100
		watch_over_date Date.new(2014, 01, 01)
		sequence(:project_id) { |n| n }
	end

	factory :cost_comment do
		cost_type 0
		comment "コメント"
		cost_memo "コストに関するメモ"
		sequence(:risk_id) { |n| n }

		factory :matter_comment do
			cost_type CostCommentModelHelper::CostCommentType::MATTER
		end

		factory :measure_comment do
			cost_type CostCommentModelHelper::CostCommentType::MEASURE
		end
	end

	factory :comment do
		sequence(:user_id) { |n| n }
		comment "コメント"
		id_type 0
		sequence(:target_id) { |n| n }
	end
end
