docs:
	terraform-docs markdown table . > README.md

test:
	terraform -chdir=examples init
	terraform -chdir=examples plan