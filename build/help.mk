.DEFAULT_GOAL := help
NC = \033[0m
ERR = \033[31;1m
TAB := '%-20s'

clr_cmd := $(shell tput setaf 202)
clr_header := $(shell tput setaf 250)
clr_make := $(shell tput setaf 240)
clr_desc := $(shell tput setaf 250)
bold := $(shell tput bold)
underline := $(shell tput smul)
reset := $(shell tput sgr0)

.PHONY: help
help:
	@printf '$(clr_header)$(shell awk -F'displayName:' '/^[[:space:]]*displayName:/ {gsub(/^[ \t]+|[ \t]+$$/, "", $$2); print $$2}' "$(SELF_DIR)/docs/catalog.yaml")$(reset)\n'
	@printf '$(clr_desc)  > $(shell awk -F'description:' '/^[[:space:]]*description:/ {gsub(/^[ \t]+|[ \t]+$$/, "", $$2); print $$2}' "$(SELF_DIR)/docs/catalog.yaml")$(reset)\n\n'
	
	@printf '    $(underline)$(clr_header)Commands:$(reset)\n\n'

	@grep -E '^([a-zA-Z0-9_-]+\.?)+:.+#.+$$' $(MAKEFILE_LIST) \
		| cut -d':' -f2- \
		| grep -v '^check-' \
		| grep -v '^env-' \
		| grep -v '^arg-' \
		| sed 's/:.*#/: #/g' \
		| awk 'BEGIN {FS = "[: ]+#[ ]+"}; \
		{printf " $(clr_make)   make $(reset)$(clr_cmd)$(bold)$(TAB) $(reset)$(clr_desc)# %s$(reset)\n", \
			$$1, $$2}'

	@printf '\n'
	@grep -E '^([a-zA-Z0-9_-]+\.?)+:(\s+|\w+)*$$' $(MAKEFILE_LIST) \
		| cut -d':' -f2- \
		| (grep -v help || true) \
		| awk 'BEGIN {FS = ":"}; \
		{printf " $(clr_make)   make $(reset)$(clr_cmd)$(bold)$(TAB)$(reset)\n", \
			$$1}'
