.PHONY: plan apply destroy
    SHELL := $(SHELL) -e

plan:
		terraform get -update
		terraform plan -var-file terraform.tfvars -out terraform.tfplan -module-depth=-1

apply:
		terraform apply -var-file terraform.tfvars

clean:
		rm -f terraform.tfplan
		rm -f terraform.tfstate
		rm -f terraform.tfstate.backup

test:
		./bin/test
