AWS_REGION ?= ""

# ----------------- SSO Environment variables  --------------------------

.PHONY: aws-check
aws-check: # Check that the AWS CLI can communicate with AWS
	@aws sts get-caller-identity

# ----------------- SSO Environment variables  --------------------------
env-AWS_REGION: # [CHECK] Checks for the env variable AWS_REGION
	@if test -z ${AWS_REGION}; then echo -e "${ERR}$(ERR_MISSING_AWS_REGION)${NC}"; exit 244; fi

# ----------------- Error Messages --------------------------
define ERR_MISSING_AWS_REGION
The environment variable 'AWS_REGION' must be defined.

Specifies the AWS Region to send requests to for commands requested using this profile.
endef