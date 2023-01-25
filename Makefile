docs:
	terraform-docs markdown table . > README.md

test:
	bundle exec rspec
