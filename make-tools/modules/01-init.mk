# ============================================================================
# PROJECT:         Makefile Ada Utils
# AUTHOR:          PyCoder Gabryl
# GITHUB:          https://github.com/PyCoder-Gabryl
# EMAIL:           pycoder.gabryl@gmail.com
# LICENSE:         Apache 2.0
# ----------------------------------------------------------------------------
# DESCRIPTION:     Moduł inicjacji projektu. Odpowiada za generowanie
#                  struktury katalogów, kopiowanie szablonów z podstawieniem
#                  zmiennych metadanych, instalację hooków Git oraz integrację
#                  z GitHubem. Zaprojektowany z myślą o pełnej idempotentności.
# ----------------------------------------------------------------------------
# PATH:            make-tools/modules/01-init.mk
# CREATED:         2026-09-04
# ============================================================================

## help-init: Pomoc dla sekcji inicjacji projektu
help-init:
	@echo "$(C_BLUE)--- GRUPA: INICJACJA PROJEKTU ---$(C_RESET)"
	@echo "  make setup-project - Tworzy strukturę i kopiuje szablony"
	@echo "  make git-init      - Inicjuje repozytorium Git i instaluje 3 hooki"
	@echo "  make gh-repo       - Tworzy repozytorium na GitHubie"
	@echo "  make git-reset     - Usuwa .git i cofa wersję (wymaga CONFIRM=1)"
	@echo "  $(C_GREEN)make init-all$(C_RESET)      - Wykonuje setup-project -> git-init -> gh-repo"

## init-all: Pełny proces inicjacji (setup -> git -> github)
init-all:
	$(call print_banner,make init-all)
	@$(MAKE) --no-print-directory setup-project
	@$(MAKE) --no-print-directory git-init
	@$(MAKE) --no-print-directory gh-repo

## setup-project: Inicjalizuje projekt: alr init + struktura src/ + szablony
setup-project:
	@echo "$(C_BLUE)==> SETUP: inicjalizacja projektu Ada / Alire...$(C_RESET)"
	@DIR_NAME="$$(basename "$$PWD")"; \
	CRATE_SUGG="$$(printf '%s' "$$DIR_NAME" | tr 'A-Z' 'a-z' | sed 's/[^a-z0-9_]/_/g; s/^_*//; s/_*$$//')"; \
	N="$(NAME)"; \
	if [ -z "$$N" ]; then \
		printf "Nazwa skrzynki Alire / pliku binarnego [%s]: " "$$CRATE_SUGG"; \
		read -r N || N=""; \
		if [ -z "$$N" ]; then N="$$CRATE_SUGG"; fi; \
	fi; \
	N="$$(printf '%s' "$$N" | tr 'A-Z' 'a-z' | sed 's/[^a-z0-9_]/_/g; s/^_*//; s/_*$$//')"; \
	FIRST_C="$$(echo "$$N" | cut -c1 | tr 'a-z' 'A-Z')"; \
	REST_C="$$(echo "$$N" | cut -c2-)"; \
	DEFAULT_GPR="$${FIRST_C}$${REST_C}"; \
	GPR_ID="$(GPR_NAME)"; \
	if [ -z "$$GPR_ID" ]; then \
		printf "Nazwa projektu GNAT / jednostki Ada [%s]: " "$$DEFAULT_GPR"; \
		read -r GPR_ID || GPR_ID=""; \
		if [ -z "$$GPR_ID" ]; then GPR_ID="$$DEFAULT_GPR"; fi; \
	fi; \
	AUTH="$(AUTHOR)"; \
	printf "Autor projektu [%s]: " "$$AUTH"; \
	read -r INPUT_AUTH || INPUT_AUTH=""; \
	if [ -n "$$INPUT_AUTH" ]; then AUTH="$$INPUT_AUTH"; fi; \
	MAIL="$(EMAIL)"; \
	printf "Adres e-mail [%s]: " "$$MAIL"; \
	read -r INPUT_MAIL || INPUT_MAIL=""; \
	if [ -n "$$INPUT_MAIL" ]; then MAIL="$$INPUT_MAIL"; fi; \
	GH_USR="$(GITHUB_USER)"; \
	printf "Login GitHub [%s]: " "$$GH_USR"; \
	read -r INPUT_GH || INPUT_GH=""; \
	if [ -n "$$INPUT_GH" ]; then GH_USR="$$INPUT_GH"; fi; \
	GH_URL="https://github.com/$$GH_USR"; \
	CURR_DATE="$$(date +%Y-%m-%d)"; \
	CURR_YEAR="$$(date +%Y)"; \
	echo "$(C_GREEN)  [1/6] Skrzynka: $$N | Jednostka: $$GPR_ID | Autor: $$AUTH <$$MAIL>$(C_RESET)"; \
	if [ -f alire.toml ]; then \
		echo "  [2/6] alire.toml już istnieje - pomijam alr init"; \
	elif command -v alr >/dev/null 2>&1; then \
		alr init -n --in-place --bin "$$N" || exit 1; \
	fi; \
	echo "  [3/6] Tworzenie katalogów: src/($(SRC_SUBDIRS)) tests doc bin obj data/config"; \
	for d in $(SRC_SUBDIRS); do mkdir -p "src/$$d"; touch "src/$$d/.gitkeep"; done; \
	mkdir -p tests doc bin obj data/config; \
	echo "  [4/6] Kopiowanie i podstawianie szablonów z: $(MAKE_TOOLS_DIR)/templates"; \
	if [ -d "$(MAKE_TOOLS_DIR)/templates" ]; then \
		for s in "$(MAKE_TOOLS_DIR)/templates"/*.tpl; do \
			[ -f "$$s" ] || continue; \
			case "$$s" in *.githook.tpl|*project.gpr.tpl) continue ;; esac; \
			d="$$(basename "$$s" .tpl)"; \
			if [ ! -f "$$d" ]; then \
				case "$$d" in \
					.editorconfig|.clang-format|.cz.toml|.gitignore) \
						cp "$$s" "$$d";; \
					*) \
						sed -e "s|@PROJECT@|$$GPR_ID|g" -e "s|@PROJECT_LOWER@|$$N|g" \
						    -e "s|@YEAR@|$$CURR_YEAR|g" -e "s|@DATE@|$$CURR_DATE|g" \
						    -e "s|@AUTHOR@|$$AUTH|g" -e "s|@EMAIL@|$$MAIL|g" \
						    -e "s|@GITHUB@|$$GH_URL|g" "$$s" > "$$d";; \
				esac; \
				echo "        [OK] $$d"; \
			else echo "        [pominięto] $$d"; fi; \
		done; \
		if [ -f "$(MAKE_TOOLS_DIR)/templates/project.gpr.tpl" ]; then \
			GPR_DEST="$$N.gpr"; \
			if [ ! -f "$$GPR_DEST" ]; then \
				sed -e "s|@PROJECT@|$$GPR_ID|g" -e "s|@PROJECT_LOWER@|$$N|g" \
				    -e "s|@YEAR@|$$CURR_YEAR|g" -e "s|@DATE@|$$CURR_DATE|g" \
				    -e "s|@AUTHOR@|$$AUTH|g" -e "s|@EMAIL@|$$MAIL|g" \
				    -e "s|@GITHUB@|$$GH_URL|g" \
				    "$(MAKE_TOOLS_DIR)/templates/project.gpr.tpl" > "$$GPR_DEST"; \
				echo "        [OK] $$GPR_DEST (Projekt GNAT)"; \
			else echo "        [pominięto] $$GPR_DEST"; fi; \
		fi; \
		if [ -d "$(MAKE_TOOLS_DIR)/templates/tests" ]; then \
			for ts in "$(MAKE_TOOLS_DIR)/templates/tests"/*.tpl; do \
				[ -f "$$ts" ] || continue; \
				td="tests/$$(basename "$$ts" .tpl)"; \
				if [ ! -f "$$td" ]; then \
					sed -e "s|@PROJECT@|$$GPR_ID|g" -e "s|@PROJECT_LOWER@|$$N|g" \
					    -e "s|@YEAR@|$$CURR_YEAR|g" -e "s|@DATE@|$$CURR_DATE|g" \
					    -e "s|@AUTHOR@|$$AUTH|g" -e "s|@EMAIL@|$$MAIL|g" \
					    -e "s|@GITHUB@|$$GH_URL|g" "$$ts" > "$$td"; \
					echo "        [OK] $$td (Uprząż AUnit)"; \
				else echo "        [pominięto] $$td"; fi; \
			done; \
		fi; \
	fi; \
	echo "  [5/6] Hooki zainstaluje make git-init"; \
	echo "  [6/6] Gotowe."

## git-init: Repozytorium Git (branch main) + hooki commit-msg, post-commit i pre-push
git-init:
	@if [ -d .git ]; then \
		echo "-> Repozytorium Git już istnieje - pomijam 'git init'"; \
	else \
		echo "-> Inicjalizacja repozytorium Git (branch main)..."; \
		git init -b main || exit 1; \
	fi
	@if [ -f "$(MAKE_TOOLS_DIR)/templates/commit-msg.githook.tpl" ]; then \
		cp "$(MAKE_TOOLS_DIR)/templates/commit-msg.githook.tpl" .git/hooks/commit-msg; \
		chmod +x .git/hooks/commit-msg; \
		echo "-> Hook commit-msg zainstalowany/zaktualizowany"; \
	fi
	@if [ -f "$(MAKE_TOOLS_DIR)/templates/post-commit.githook.tpl" ]; then \
		cp "$(MAKE_TOOLS_DIR)/templates/post-commit.githook.tpl" .git/hooks/post-commit; \
		chmod +x .git/hooks/post-commit; \
		echo "-> Hook post-commit zainstalowany/zaktualizowany"; \
	fi
	@if [ -f "$(MAKE_TOOLS_DIR)/templates/pre-push.githook.tpl" ]; then \
		cp "$(MAKE_TOOLS_DIR)/templates/pre-push.githook.tpl" .git/hooks/pre-push; \
		chmod +x .git/hooks/pre-push; \
		echo "-> Hook pre-push zainstalowany/zaktualizowany"; \
	fi

## gh-repo: Tworzy repozytorium na GitHubie (gh, SSH) i wypycha kod (push)
gh-repo:
	@if ! command -v gh >/dev/null 2>&1; then echo "$(C_RED)Brak gh$(C_RESET)"; exit 1; fi
	@if [ ! -d .git ]; then $(MAKE) --no-print-directory git-init; fi
	@R="$(REPO_NAME)"; if [ -z "$$R" ]; then R="$$(basename "$$PWD")"; fi; \
	U="$$(gh api user -q .login)" || exit 1; \
	if gh repo view "$$U/$$R" >/dev/null 2>&1; then \
		echo "-> Repozytorium $$U/$$R już istnieje na GitHubie - pomijam tworzenie"; \
	else \
		echo "-> Tworzenie repozytorium $$U/$$R na GitHubie..."; \
		gh repo create "$$R" --$(REPO_VISIBILITY) || exit 1; \
	fi; \
	git remote remove origin 2>/dev/null || true; \
	git remote add origin "git@github.com:$$U/$$R.git"; \
	git push -u origin main || \
		echo "$(C_YELLOW)-> Uwaga: push się nie powiódł (może brak commitów?)$(C_RESET)"; \
	echo "$(C_GREEN)==> Integracja z GitHubem zakończona.$(C_RESET)"

## git-reset: Usuwa .git i cofa wersję do 0.1.0 (wymaga CONFIRM=1)
git-reset:
	@if [ "$(CONFIRM)" != "1" ]; then echo "$(C_RED)Potwierdź: make git-reset CONFIRM=1$(C_RESET)"; exit 1; fi
	@$(RM) .git
	@echo "0.1.0" > VERSION
	@echo "$(C_GREEN)==> Repozytorium usunięte.$(C_RESET)"

.PHONY: help-init init-all setup-project git-init gh-repo git-reset
