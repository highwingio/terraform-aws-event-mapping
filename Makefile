docs:
	terraform-docs markdown table . > README.md

test:
	terraform -chdir=examples plan