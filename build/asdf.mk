asdf-info: # Emit information about asdf
	@asdf info

	@echo "ASDF Current Tool Versions"
	@asdf current

	@echo "ASDF Latest Versions"
	@asdf latest --all

	@echo "ASDF Plugin symlink directories"
	@asdf plugin list || true
	if [ -d "~/.asdf/plugins" ]; then ls -l ~/.asdf/plugins; fi

asdf-latest: # Install latest version of toolchains
	@cat .tool-versions | cut -d' ' -f1 | xargs -I% asdf install % latest
	@cat .tool-versions | cut -d' ' -f1 | xargs -I% bash % version
