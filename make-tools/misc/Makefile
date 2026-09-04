#  =============================================================================
#  PROJECT:          Gabyx
#  AUTHOR:           PyCoder Gabryl
#  EMAIL:            pycoder.gabryl@gmail.com
#  GITHUB:           https://github.com/PyCoder-Gabryl/
#  LICENSE.tpl:          Apache License 2.0
#  -----------------------------------------------------------------------------
#  DESCRIPTION:      Workflow Engine v2. Cztery metasekcje cyklu życia projektu:
#                    (1) inicjacja, (2) codzienna praca, (3) testy/dowody/info,
#                    (4) wydanie. Sam wykrywa plik *.gpr, szablony plików kopiuje
#                    z katalogu make-templ/ (lokalnego lub ~/make-templ), a każdy
#                    target kończy się informacją zwrotną: co zrobione i jaki
#                    jest następny krok.
#  -----------------------------------------------------------------------------
#  PATH:             Makefile
#  CREATED:          2026-07-07
#  =============================================================================

#  -----------------------------------------------------------------------------
#  START:            make help      - płaska lista wszystkich targetów
#                    make workflow  - przewodnik po metasekcjach (pełna mapa)
#                    make doctor    - diagnostyka narzędzi i ścieżek
#  -----------------------------------------------------------------------------
#  Nadpisywanie:     make GPR_FILE=moj.gpr <cel>
#                    make setup-project NAME=nazwa   (bez pytania o nazwę)
#                    make gh-repo REPO_NAME=nazwa    (bez pytania o nazwę)
#                    make bump LEVEL=patch|minor|major
#  =============================================================================

#  =============================================================================
#  0. KOLORY, ŚRODOWISKO, WYKRYWANIE PROJEKTU
#  =============================================================================
C_RESET  := \033[0m
C_BLUE   := \033[34;1m
C_GREEN  := \033[32;1m
C_YELLOW := \033[33;1m
C_RED    := \033[31;1m
C_CYAN   := \033[36;1m

#  Plik projektu: pierwszy *.gpr w katalogu głównym, z pominięciem
#  wygenerowanego przez gnatcov pliku gnatcov_rts.gpr.
GPR_FILE     ?= $(firstword $(filter-out gnatcov_rts.gpr,$(wildcard *.gpr)))
PROJECT_NAME ?= $(basename $(notdir $(GPR_FILE)))
#  Nazwa binarki (nadpisz tylko, jeśli różni się od nazwy projektu):
EXE_NAME     ?= $(PROJECT_NAME)

#  Nazwa projektu/repo dla targetów pytających (pusta = target zapyta):
NAME         ?=
REPO_NAME    ?=

#  Katalog szablonów: lokalny make-templ/, a gdy go brak: ~/make-templ
#  (fallback realizowany w przepisach, więc można nadpisać z linii poleceń)
MAKE_TEMPL_DIR ?= $(CURDIR)/make-templ

#  Podkatalogi src/ tworzone przez setup-project (nadpisz wg własnej architektury)
SRC_SUBDIRS  ?= config core i18n logging app driver ui

#  Autor wstawiany w szablony (placeholdery: @PROJECT@ @YEAR@ @AUTHOR@ @EMAIL@)
AUTHOR       ?= PyCoder Gabryl
EMAIL        ?= pycoder.gabryl@gmail.com

#  Projekt testowy AUnit (własna uprząż, niezależna od projektu głównego):
TEST_GPR     := tests/tests.gpr
TEST_RUNNER  := tests/bin/test_runner

#  GNATtest (test-gen / test-gnattest):
HARNESS_DIR   := tests/harness
HARNESS_GPR   := $(HARNESS_DIR)/test_driver.gpr
HARNESS_BIN   := $(HARNESS_DIR)/test_runner
GEN_TESTS_DIR := tests/gen

VERSION       := $(shell cat VERSION 2>/dev/null || echo "0.1.0")
CONTEXT_OUT   := context.txt
COV_REPORT    := coverage_report
COV_RTS_DIR   := $(CURDIR)/gnatcov_rts
COV_LEVEL     := stmt+decision
PROVE_TIMEOUT ?= 30
REPO_VISIBILITY ?= private
LEVEL         ?= patch
DIR           ?= core

RM            := rm -rf

#  =============================================================================
#  ŚRODOWISKO (UTF-8 + narzędzia Alire w PATH)
#  =============================================================================
export LANG   := pl_PL.UTF-8
export LC_ALL := pl_PL.UTF-8
export PATH   := $(shell echo $$HOME)/.alire/bin:$(PATH)

#  =============================================================================
#  META-SEKCJA 0: POMOC I DOKUMENTACJA
#  =============================================================================

## help: Wyświetla płaską listę wszystkich dostępnych poleceń
help:
	@echo "$(C_BLUE)======================================================================$(C_RESET)"
	@echo "$(C_BLUE)         $(PROJECT_NAME) - CENTRUM AUTOMATYZACJI (workflow v2)         $(C_RESET)"
	@echo "$(C_BLUE)======================================================================$(C_RESET)"
	@grep -h '^## ' $(MAKEFILE_LIST) | sed 's/^## //' | while IFS= read -r line; do \
		name=$$(printf '%s' "$$line" | cut -d: -f1); \
		desc=$$(printf '%s' "$$line" | cut -d: -f2-); \
		printf "  $(C_CYAN)%-16s$(C_RESET) %s\n" "$$name" "$$desc"; \
	done
	@echo ""
	@echo "$(C_YELLOW)Przewodnik po metasekcjach: make workflow$(C_RESET)"

## workflow: Przewodnik po cyklu deweloperskim - 4 metasekcje (Alias: wf)
workflow wf:
	@echo "$(C_BLUE)======================================================================$(C_RESET)"
	@echo "$(C_BLUE)  PRZEWODNIK PO CYKLU ŻYCIA PROJEKTU ($(PROJECT_NAME)) - 4 METASEKCJE$(C_RESET)"
	@echo "$(C_BLUE)======================================================================$(C_RESET)"
	@echo "$(C_GREEN)[1/4] INICJACJA PROJEKTU$(C_RESET)"
	@echo "  make setup-project [NAME=x] - alr init -n --in-place (--no-skel gdy jest .gpr)"
	@echo "                                + src/<podkatalogi> + szablony z make-templ/"
	@echo "  make doctor                 - raport: narzędzia OK/BRAK + wykryte ścieżki"
	@echo "  make index-update           - alr index --update-all (aktualizacja indeksu)"
	@echo "  make git-init               - repo Git (main) + hooki commit-msg i post-commit"
	@echo "  make gh-repo [REPO_NAME=x]  - repo na GitHubie przez gh (SSH) + push;"
	@echo "                                jeśli brak .git - najpierw sam zrobi git-init"
	@echo "  make git-reset CONFIRM=1    - odwrócenie: usuwa .git, wersja wraca do 0.1.0"
	@echo ""
	@echo "$(C_GREEN)[2/4] CODZIENNA PRACA$(C_RESET)"
	@echo "  make build / build-release  - kompilacja debug / produkcyjna (-O3)"
	@echo "  make run / run-bin          - uruchomienie przez alr / binarki z bin/"
	@echo "  make syntax                 - szybka kontrola semantyki (gnatc)"
	@echo "  make format                 - formatowanie kodu (gnatpp)"
	@echo "  make new-module NAME=x [DIR=core] - nowy moduł src/DIR/projekt-dir-x.ad[sb]"
	@echo "  make todos                  - lista TODO/FIXME w src/ i tests/"
	@echo "  make clean                  - sprzątanie artefaktów"
	@echo ""
	@echo "$(C_GREEN)[3/4] TESTY, DOWODY I INFORMACJA O PROJEKCIE$(C_RESET)"
	@echo "  make test                   - testy Alire (akcja [test] z alire.toml)"
	@echo "  make test-aunit             - nasza uprząż AUnit (tests/tests.gpr)"
	@echo "  make test-gen               - GNATtest: szkielety testów + harness"
	@echo "  make test-gnattest          - kompilacja i bieg harnessa GNATtest"
	@echo "  make prove-l1 / prove-l2 / prove-l3 - dowody SPARK (rosnąco);"
	@echo "  make prove                  - alias dla prove-l2 (domyślny poziom dowodu)"
	@echo "  make coverage (cov)         - pokrycie kodu GNATcov (raport HTML/XCOV)"
	@echo "  make show-coverage          - otwarcie katalogu z raportem"
	@echo "  make metrics (mt)           - złożoność cyklomatyczna (gnatmetric)"
	@echo "  make info                   - diagnostyka projektu (gprls)"
	@echo "  make dump-context (ctx)     - kontekst architektury dla AI (context.txt)"
	@echo ""
	@echo "$(C_GREEN)[4/4] WYDANIE I WERSJONOWANIE$(C_RESET)"
	@echo "  make bump LEVEL=patch|minor|major - podbicie VERSION + alire.toml + .cz.toml"
	@echo "  make package                - archiwum ZIP wydania w dist/"
	@echo ""
	@echo "$(C_YELLOW)Konwencja feedbacku: każdy target kończy się linią '==>' (co zrobione)"
	@echo "i linią 'następny krok' (co wywołać dalej). Pełna płaska lista: make help$(C_RESET)"

#  =============================================================================
#  META-SEKCJA 1: INICJACJA PROJEKTU (BOOTSTRAP)
#  =============================================================================

## doctor: Diagnostyka środowiska: narzędzia OK/BRAK + wykryte ścieżki
doctor:
	@echo "$(C_BLUE)==> Diagnostyka środowiska Ada/Alire...$(C_RESET)"
	@MISS=0; \
	for t in alr gprbuild gnatprove gnatcov git gh zip; do \
		if command -v $$t >/dev/null 2>&1; then \
			printf "  $(C_GREEN)[OK]  $(C_RESET) %-10s %s\n" "$$t" "$$(command -v $$t)"; \
		else \
			printf "  $(C_RED)[BRAK]$(C_RESET) %s\n" "$$t"; MISS=$$((MISS + 1)); \
		fi; \
	done; \
	echo "  ----------------------------------------------------------------"; \
	printf "  GPR_FILE       : %s\n" "$(GPR_FILE)"; \
	printf "  PROJECT_NAME   : %s\n" "$(PROJECT_NAME)"; \
	printf "  VERSION        : %s\n" "$(VERSION)"; \
	printf "  MAKE_TEMPL_DIR : %s\n" "$(MAKE_TEMPL_DIR)"; \
	printf "  SRC_SUBDIRS    : %s\n" "$(SRC_SUBDIRS)"; \
	if [ $$MISS -gt 0 ]; then \
		echo "$(C_YELLOW)==> Brakujących narzędzi: $$MISS (gh opcjonalne: make gh-repo)$(C_RESET)"; \
	else \
		echo "$(C_GREEN)==> Wszystkie narzędzia obecne.$(C_RESET)"; \
	fi

## index-update: Aktualizuje indeksy Alire (alr index --update-all)
index-update:
	@if ! command -v alr >/dev/null 2>&1; then \
		echo "$(C_RED)Brak alr w PATH - uruchom make doctor.$(C_RESET)"; \
		exit 1; \
	fi
	@echo "$(C_BLUE)==> Aktualizacja indeksów Alire...$(C_RESET)"
	@alr index --update-all
	@echo "$(C_GREEN)==> Indeksy Alire zaktualizowane.$(C_RESET)"
	@echo "$(C_YELLOW)    następny krok: make doctor$(C_RESET)"

## setup-project: Inicjalizuje projekt: alr init + struktura src/ + szablony
setup-project:
	@echo "$(C_BLUE)==> SETUP: inicjalizacja projektu Ada/Alire...$(C_RESET)"
	@N="$(NAME)"; \
	if [ -z "$$N" ]; then \
		D="$$(basename "$$PWD" | tr 'A-Z' 'a-z' | sed 's/[^a-z0-9_]/_/g')"; \
		printf "Nazwa projektu [%s]: " "$$D"; \
		read -r N || N=""; \
		if [ -z "$$N" ]; then N=$$D; fi; \
	fi; \
	N="$$(printf '%s' "$$N" | tr 'A-Z' 'a-z' | sed 's/[^a-z0-9_]/_/g; s/^_*//; s/_*$$//')"; \
	case "$$N" in \
		[a-z]*) : ;; \
		*) echo "$(C_RED)Błąd: nazwa '$$N' łamie reguły Alire (zacznij od litery; a-z 0-9 _).$(C_RESET)"; exit 1 ;; \
	esac; \
	echo "$(C_GREEN)  [1/6] Nazwa projektu: $$N$(C_RESET)"; \
	if [ -f alire.toml ]; then \
		echo "  [2/6] alire.toml już istnieje - pomijam alr init"; \
	elif command -v alr >/dev/null 2>&1; then \
		if [ -n "$(GPR_FILE)" ]; then \
			echo "  [2/6] Wykryto $(GPR_FILE): alr init -n --in-place --no-skel $$N"; \
			alr init -n --in-place --no-skel "$$N" || exit 1; \
		else \
			echo "  [2/6] Brak .gpr: alr init -n --in-place --bin $$N (szkielet)"; \
			alr init -n --in-place --bin "$$N" || exit 1; \
		fi; \
	else \
		echo "$(C_YELLOW)  [2/6] Brak alr w PATH - pomijam alr init (sprawdź: make doctor)$(C_RESET)"; \
	fi; \
	echo "  [3/6] Katalogi: src/($(SRC_SUBDIRS)) tests doc bin obj"; \
	for d in $(SRC_SUBDIRS); do \
		mkdir -p "src/$$d"; \
		[ -f "src/$$d/.gitkeep" ] || touch "src/$$d/.gitkeep"; \
	done; \
	mkdir -p tests doc bin obj; \
	T="$(MAKE_TEMPL_DIR)"; \
	if [ ! -d "$$T" ]; then T="$(HOME)/make-templ"; fi; \
	echo "  [4/6] Szablony plików z: $$T (nigdy nie nadpisuje istniejących)"; \
	if [ -d "$$T" ]; then \
		if [ ! -f Makefile ] && [ -f "$$T/Makefile" ]; then \
			cp "$$T/Makefile" Makefile; \
			echo "        [OK] Makefile (skopiowany - bootstrap)"; \
		fi; \
		for pair in "README.md.tpl README.md" "ROADMAP.md.tpl ROADMAP.md" \
		            "VERSION.tpl VERSION" "LICENSE.apache-2.0 LICENSE" \
		            ".gitignore.tpl .gitignore" ".editorconfig.tpl .editorconfig" \
		            "CONTRIBUTING.md.tpl CONTRIBUTING.md" ".clang-format.tpl .clang-format" \
		            ".cz.toml.tpl .cz.toml"; do \
			s="$$T/$$(printf '%s' "$$pair" | cut -d' ' -f1)"; \
			d="$$(printf '%s' "$$pair" | cut -d' ' -f2)"; \
			if [ -f "$$d" ]; then \
				echo "        [pominięto] $$d (już istnieje)"; \
			elif [ -f "$$s" ]; then \
				sed -e "s|@PROJECT@|$$N|g" -e "s|@YEAR@|$$(date +%Y)|g" \
				    -e "s|@AUTHOR@|$(AUTHOR)|g" -e "s|@EMAIL@|$(EMAIL)|g" \
				    "$$s" > "$$d"; \
				echo "        [OK] $$d"; \
			else \
				echo "        [brak szablonu] $$s"; \
			fi; \
		done; \
	else \
		echo "$(C_YELLOW)        brak katalogu szablonów - pomijam (MAKE_TEMPL_DIR)$(C_RESET)"; \
	fi; \
	if [ -d .git ]; then \
		if [ -f "$(MAKE_TEMPL_DIR)/commit-msg.githook" ]; then \
			cp "$(MAKE_TEMPL_DIR)/commit-msg.githook" .git/hooks/commit-msg; \
			chmod +x .git/hooks/commit-msg; \
		fi; \
		if [ -f "$(MAKE_TEMPL_DIR)/post-commit.githook" ]; then \
			cp "$(MAKE_TEMPL_DIR)/post-commit.githook" .git/hooks/post-commit; \
			chmod +x .git/hooks/post-commit; \
		fi; \
		echo "  [5/6] Hooki commit-msg i post-commit odświeżone"; \
	else \
		echo "  [5/6] Hooki commit-msg i post-commit zainstaluje make git-init"; \
	fi; \
	echo "  [6/6] Feedback - ręczna korekta alire.toml po alr init -n:"; \
	echo "        - authors / maintainers / licenses / tags / website / description"; \
	echo "        - [test] command = ... (jeśli akcja testów ma być widoczna dla alr)"; \
	echo "        - jeśli GPR ma inne Source_Dirs: sprawdź src/** w $(GPR_FILE)"
	@echo "$(C_GREEN)==> Struktura projektu gotowa dla nazwy powyżej.$(C_RESET)"
	@echo "$(C_YELLOW)    następny krok: make git-init -> make gh-repo -> make build$(C_RESET)"

## git-init: Repozytorium Git (branch main) + hooki commit-msg i post-commit
git-init:
	@if [ -d .git ]; then \
		echo "-> Repozytorium Git już istnieje."; \
	else \
		echo "-> Inicjalizacja repozytorium Git (branch main)..."; \
		git init -b main || exit 1; \
	fi
	@if [ -f "$(MAKE_TEMPL_DIR)/commit-msg.githook" ]; then \
		cp "$(MAKE_TEMPL_DIR)/commit-msg.githook" .git/hooks/commit-msg; \
		chmod +x .git/hooks/commit-msg; \
		echo "-> Hook commit-msg zainstalowany (walidacja prefiksu: add/fix/docs/...)."; \
	else \
		echo "-> Brak szablonu hooka commit-msg w $(MAKE_TEMPL_DIR) - pomijam."; \
	fi
	@if [ -f "$(MAKE_TEMPL_DIR)/post-commit.githook" ]; then \
		cp "$(MAKE_TEMPL_DIR)/post-commit.githook" .git/hooks/post-commit; \
		chmod +x .git/hooks/post-commit; \
		echo "-> Hook post-commit zainstalowany (auto-bump wersji przez commitizen)."; \
	else \
		echo "-> Brak szablonu hooka post-commit w $(MAKE_TEMPL_DIR) - pomijam."; \
	fi
	@echo "$(C_GREEN)==> Repozytorium Git gotowe.$(C_RESET)"
	@echo "$(C_YELLOW)    następny krok: make gh-repo (utworzy repo na GitHubie i wyśle kod)$(C_RESET)"

## gh-repo: Tworzy repozytorium na GitHubie (gh, SSH) i wypycha kod (push)
gh-repo:
	@if ! command -v gh >/dev/null 2>&1; then \
		echo "$(C_RED)Brak GitHub CLI (gh). Instalacja: https://cli.github.com/$(C_RESET)"; \
		exit 1; \
	fi
	@if ! gh auth status >/dev/null 2>&1; then \
		echo "$(C_RED)gh niezalogowany. Uruchom: gh auth login (protokół: SSH).$(C_RESET)"; \
		exit 1; \
	fi
	@if [ ! -d .git ]; then \
		echo "-> Brak repo Git - wykonuję make git-init..."; \
		$(MAKE) --no-print-directory git-init; \
	fi
	@R="$(REPO_NAME)"; \
	if [ -z "$$R" ]; then \
		D="$(PROJECT_NAME)"; \
		if [ -z "$$D" ]; then D="$$(basename "$$PWD" | tr 'A-Z' 'a-z')"; fi; \
		printf "Nazwa repozytorium na GitHubie [%s]: " "$$D"; \
		read -r R || R=""; \
		if [ -z "$$R" ]; then R=$$D; fi; \
	fi; \
	U="$$(gh api user -q .login)" || exit 1; \
	echo "-> Tworzę $$U/$$R (widoczność: $(REPO_VISIBILITY); protokół: SSH)..."; \
	gh repo create "$$R" --$(REPO_VISIBILITY) || exit 1; \
	git remote remove origin 2>/dev/null || true; \
	git remote add origin "git@github.com:$$U/$$R.git"; \
	git push -u origin main || exit 1; \
	echo "$(C_CYAN)==> Repozytorium: git@github.com:$$U/$$R.git$(C_RESET)"
	@echo "$(C_GREEN)==> Kod wypchnięty na GitHub przez SSH.$(C_RESET)"
	@echo "$(C_YELLOW)    następny krok: gh repo view --web$(C_RESET)"

## git-reset: Usuwa .git i cofa wersję do 0.1.0 (wymaga CONFIRM=1)
git-reset:
	@if [ "$(CONFIRM)" != "1" ]; then \
		echo "$(C_RED)Operacja destrukcyjna. Potwierdź: make git-reset CONFIRM=1$(C_RESET)"; \
		exit 1; \
	fi
	@$(RM) .git
	@echo "0.1.0" > VERSION
	@if [ -f alire.toml ]; then sed -i 's/^version = .*/version = "0.1.0"/' alire.toml; fi
	@if [ -f .cz.toml ]; then sed -i 's/^version = .*/version = "0.1.0"/' .cz.toml; fi
	@echo "$(C_GREEN)==> Repozytorium usunięte; wersja wróciła do 0.1.0.$(C_RESET)"
	@echo "$(C_YELLOW)    następny krok: make git-init$(C_RESET)"

#  =============================================================================
#  META-SEKCJA 2: CODZIENNA PRACA (BUDOWANIE I URUCHAMIANIE)
#  =============================================================================

## build: Budowanie projektu w trybie debug
build:
	@echo "$(C_BLUE)==> Budowanie projektu $(PROJECT_NAME) (debug)...$(C_RESET)"
	@alr build -- -j0
	@echo "$(C_GREEN)==> Kompilacja debug zakończona pomyślnie.$(C_RESET)"
	@echo "$(C_YELLOW)    następny krok: make run lub make test-aunit$(C_RESET)"

## build-release: Budowanie produkcyjne z optymalizacją (Alias: build-prod)
build-release build-prod:
	@echo "$(C_BLUE)==> Budowanie projektu $(PROJECT_NAME) (release)...$(C_RESET)"
	@alr build --release -- -j0
	@echo "$(C_GREEN)==> Kompilacja produkcyjna zakończona sukcesem.$(C_RESET)"
	@echo "$(C_YELLOW)    następny krok: make run-bin$(C_RESET)"

## run: Uruchamianie programu przez Alire
run:
	@echo "$(C_BLUE)==> Uruchamianie $(PROJECT_NAME)...$(C_RESET)"
	@alr run
	@echo "$(C_GREEN)==> Program zakończył działanie.$(C_RESET)"
	@echo "$(C_YELLOW)    następny krok: make test-aunit lub make prove-l1$(C_RESET)"

## run-bin: Uruchomienie zbudowanej binarki bezpośrednio z bin/
run-bin:
	@./bin/$(EXE_NAME)

## clean: Usuwanie plików binarnych, obiektowych i artefaktów
clean:
	@echo "$(C_YELLOW)==> Czyszczenie projektu i artefaktów...$(C_RESET)"
	@find . ~/.local/share/alire/builds -type f \
		\( -name "*.stdout" -o -name "*.stderr" -o -name "*.cswi" -o -name "*.lexch" \) \
		-delete 2>/dev/null || true
	@$(RM) obj bin gnatcov_rts gnatcov_rts.gpr *.trace *.srctrace *.map context.txt
	@$(RM) tests/obj tests/bin
	@alr clean
	@echo "$(C_GREEN)==> Projekt został wyczyszczony.$(C_RESET)"

## syntax: Szybkie sprawdzenie poprawności semantyki (gnatc)
syntax:
	@echo "$(C_BLUE)==> Sprawdzanie składni i semantyki...$(C_RESET)"
	@alr exec gprbuild -- -c -gnatc -P $(GPR_FILE)
	@echo "$(C_GREEN)==> Semantyka poprawna.$(C_RESET)"
	@echo "$(C_YELLOW)    następny krok: make format lub make build$(C_RESET)"

## format: Automatyczne formatowanie kodu źródłowego (gnatpp)
format:
	@echo "$(C_BLUE)==> Automatyczne formatowanie kodu (gnatpp)...$(C_RESET)"
	@alr exec gnatpp -- -P $(GPR_FILE) -r
	@echo "$(C_GREEN)==> Formatowanie zakończone pomyślnie.$(C_RESET)"
	@echo "$(C_YELLOW)    następny krok: make syntax$(C_RESET)"

## new-module: Tworzy nowy moduł src/DIR/projekt-dir-nazwa.ads + .adb
new-module:
	@N="$(NAME)"; D="$(DIR)"; \
	if [ -z "$$N" ]; then \
		echo "Użycie: make new-module NAME=nazwa [DIR=podkatalog src/]"; \
		echo "Domyślnie DIR=$(DIR). Przyklad: make new-module NAME=logger DIR=logging"; \
		exit 1; \
	fi; \
	if [ -z "$(PROJECT_NAME)" ]; then \
		echo "$(C_RED)Nie wykryto nazwy projektu (brak *.gpr w korzeniu).$(C_RESET)"; \
		echo "$(C_RED)Uruchom make setup-project albo podaj GPR_FILE=projekt.gpr.$(C_RESET)"; \
		exit 1; \
	fi; \
	N="$$(printf '%s' "$$N" | tr 'A-Z' 'a-z' | sed 's/[^a-z0-9_.]/_/g')"; \
	if [ -n "$$D" ]; then U="$$D.$$N"; else U="$$N"; fi; \
	UNIT="$(PROJECT_NAME)-$$(printf '%s' "$$U" | sed 's/\./-/g')"; \
	PKG="$$(printf '%s' "$(PROJECT_NAME).$$U" | sed -E 's/(^|\.)([a-z0-9])/\1\u\2/g')"; \
	SDIR="src/$$D"; mkdir -p "$$SDIR"; \
	if [ -f "$$SDIR/$$UNIT.ads" ]; then echo "$(C_YELLOW)Moduł już istnieje: $$SDIR/$$UNIT.ads$(C_RESET)"; exit 1; fi; \
	( echo "--  $(PROJECT_NAME): moduł $$U (1 plik = 1 odpowiedzialność)"; \
	  echo "package $$PKG is"; \
	  echo "   pragma SPARK_Mode (On);"; \
	  echo ""; \
	  echo "   --  TODO: uzupełnij interfejs modułu (kontrakty Pre/Post)"; \
	  echo ""; \
	  echo "end $$PKG;"; ) > "$$SDIR/$$UNIT.ads"; \
	( echo "package body $$PKG is"; \
	  echo ""; \
	  echo "end $$PKG;"; ) > "$$SDIR/$$UNIT.adb"; \
	echo "$(C_GREEN)==> Utworzono: $$SDIR/$$UNIT.ads + .adb (pakiet $$PKG)$(C_RESET)"
	@echo "$(C_YELLOW)    następny krok: make syntax -> make prove-l1$(C_RESET)"

## todos: Wypisuje wszystkie znaczniki TODO i FIXME w src/ i tests/
todos:
	@echo "$(C_BLUE)==> Przegląd TODO/FIXME...$(C_RESET)"
	@grep -rn -E "TODO|FIXME" src tests 2>/dev/null || echo "$(C_GREEN)  Brak znaczników TODO/FIXME.$(C_RESET)"

#  =============================================================================
#  META-SEKCJA 3: TESTY, DOWODY (SPARK) I INFORMACJA O PROJEKCIE
#  =============================================================================

## test: Uruchamia testy Alire (akcja [test] z alire.toml.tpl)
test test-alire:
	@alr test

## test-aunit: Kompiluje i uruchamia własną uprząż AUnit (tests/tests.gpr)
test-aunit:
	@echo "$(C_BLUE)==> Kompilacja testów AUnit...$(C_RESET)"
	@alr exec gprbuild -- -p -P $(TEST_GPR) -j0
	@echo "$(C_BLUE)==> Uruchamianie testów...$(C_RESET)"
	@$(TEST_RUNNER)
	@echo "$(C_GREEN)==> Testy AUnit zakończone.$(C_RESET)"
	@echo "$(C_YELLOW)    następny krok: make coverage lub make prove-l1$(C_RESET)"

## test-gen: GNATtest - generuje szkielety testów i harness (tests/harness)
test-gen:
	@echo "$(C_BLUE)==> GNATtest: generowanie szkieletów testów i harnessa...$(C_RESET)"
	@alr exec -- gnattest -P $(GPR_FILE) --harness-dir=$(HARNESS_DIR) --tests-dir=$(GEN_TESTS_DIR)
	@echo "$(C_GREEN)==> Szkielety testów i harness wygenerowane.$(C_RESET)"
	@echo "$(C_YELLOW)    następny krok: make test-gnattest$(C_RESET)"

## test-gnattest: Kompiluje i uruchamia harness wygenerowany przez GNATtest
test-gnattest:
	@echo "$(C_BLUE)==> GNATtest: kompilacja i uruchomienie harnessa...$(C_RESET)"
	@if [ ! -f $(HARNESS_GPR) ]; then echo "$(C_RED)Brak $(HARNESS_GPR) - najpierw: make test-gen$(C_RESET)"; exit 1; fi
	@alr exec -- gprbuild -P $(HARNESS_GPR) -j0
	@./$(HARNESS_BIN)
	@echo "$(C_GREEN)==> Harness GNATtest zakończony.$(C_RESET)"
	@echo "$(C_YELLOW)    następny krok: make coverage$(C_RESET)"

## prove-l1: Analiza przepływu danych (Poziom 1)
prove-l1:
	@echo "$(C_BLUE)==> SPARK: Analiza przepływu danych (Poziom 1)...$(C_RESET)"
	@alr exec gnatprove -- -P $(GPR_FILE) --level=1 -XSPARK_MODE=On --timeout=$(PROVE_TIMEOUT)
	@echo "$(C_GREEN)==> Dowód poziomu 1 zakończony.$(C_RESET)"
	@echo "$(C_YELLOW)    następny krok: make prove-l2$(C_RESET)"

## prove-l2: Dowód braku błędów wykonania (Poziom 2)
prove-l2:
	@echo "$(C_BLUE)==> SPARK: Dowód braku błędów wykonania (Poziom 2)...$(C_RESET)"
	@alr exec gnatprove -- -P $(GPR_FILE) --level=2 -XSPARK_MODE=On --timeout=$(PROVE_TIMEOUT)
	@echo "$(C_GREEN)==> Dowód poziomu 2 zakończony.$(C_RESET)"
	@echo "$(C_YELLOW)    następny krok: make prove-l3$(C_RESET)"

## prove-l3: Dowód poprawności kontraktów Pre/Post (Poziom 3)
prove-l3:
	@echo "$(C_BLUE)==> SPARK: Weryfikacja kontraktów Pre/Post (Poziom 3)...$(C_RESET)"
	@alr exec gnatprove -- -P $(GPR_FILE) --level=3 -XSPARK_MODE=On --timeout=$(PROVE_TIMEOUT)
	@echo "$(C_GREEN)==> Dowód poziomu 3 zakończony.$(C_RESET)"
	@echo "$(C_YELLOW)    następny krok: make coverage$(C_RESET)"

## prove: Domyślny poziom dowodzenia SPARK (alias dla prove-l2)
prove: prove-l2

## coverage: Generuje raport pokrycia kodu testami (GNATcov, XCOV)
coverage cov: clean
	@echo "$(C_BLUE)==> KROK 0: Inicjalizacja lokalnego runtime GNATcov...$(C_RESET)"
	@alr exec -- gnatcov setup --prefix=$(COV_RTS_DIR)
	@echo "$(C_BLUE)==> KROK 1: Instrumentacja kodu źródłowego...$(C_RESET)"
	@alr exec -- sh -c 'GPR_PROJECT_PATH="$(COV_RTS_DIR)/share/gpr:$$GPR_PROJECT_PATH" \
		gnatcov instrument -P $(GPR_FILE) --level=$(COV_LEVEL) --projects=$(PROJECT_NAME)'
	@echo "$(C_BLUE)==> KROK 2: Kompilacja instrumentowanych plików...$(C_RESET)"
	@alr exec -- sh -c 'GPR_PROJECT_PATH="$(COV_RTS_DIR)/share/gpr:$$GPR_PROJECT_PATH" \
		gprbuild -P $(GPR_FILE) -j0 --src-subdirs=gnatcov-instr --implicit-with=gnatcov_rts.gpr'
	@echo "$(C_BLUE)==> KROK 3: Uruchomienie i generowanie śladu...$(C_RESET)"
	@alr exec -- sh -c 'GNATCOV_TRACE_FILE=$(PROJECT_NAME).trace ./bin/$(EXE_NAME)'
	@echo "$(C_BLUE)==> KROK 4: Generowanie raportu HTML...$(C_RESET)"
	@mkdir -p $(COV_REPORT)
	@alr exec -- sh -c 'gnatcov coverage -P $(GPR_FILE) --level=$(COV_LEVEL) \
		--annotate=xcov --output-dir=$(COV_REPORT) $(PROJECT_NAME).trace'
	@echo "$(C_GREEN)==> Pokrycie kodu policzone.$(C_RESET)"
	@echo "$(C_YELLOW)    następny krok: make show-coverage$(C_RESET)"

## show-coverage: Otwiera katalog z raportami pokrycia XCOV
show-coverage:
	@if [ -d $(COV_REPORT) ]; then \
		echo "$(C_BLUE)==> Otwieranie raportów XCOV...$(C_RESET)"; \
		if [ "$$(uname -s)" = "Darwin" ]; then open $(COV_REPORT); else xdg-open $(COV_REPORT); fi; \
	else \
		echo "$(C_RED)Błąd: Raport nie istnieje. Uruchom 'make coverage'.$(C_RESET)"; \
	fi

## metrics: Analizuje złożoność cyklomatyczną i kontrakty (Alias: mt)
metrics mt:
	@echo "$(C_BLUE)==> Analiza metryk kodu (gnatmetric)...$(C_RESET)"
	@alr exec gnatmetric -- -P $(GPR_FILE)
	@echo "$(C_GREEN)==> Metryki wygenerowane.$(C_RESET)"
	@echo "$(C_YELLOW)    następny krok: make info$(C_RESET)"

## info: Wyświetla informacje o projekcie i środowisku (gprls)
info:
	@echo "$(C_BLUE)==> Diagnostyka projektu Ada (gprls)...$(C_RESET)"
	@alr exec gprls -- -P $(GPR_FILE)
	@echo "$(C_GREEN)==> Informacje o projekcie wypisane.$(C_RESET)"
	@echo "$(C_YELLOW)    następny krok: make dump-context$(C_RESET)"

## dump-context: Agreguje architekturę dla AI do context.txt (Alias: ctx)
dump-context ctx:
	@echo "$(C_BLUE)==> Agregacja kontekstu architektury dla AI...$(C_RESET)"
	@printf "=== STRUKTURA PROJEKTU %s (%s) ===\n" "$(PROJECT_NAME)" "$$(date)" > $(CONTEXT_OUT)
	@find . -maxdepth 3 -not -path '*/.*' -not -path './obj*' -not -path './bin*' -not -path './alire*' >> $(CONTEXT_OUT)
	@printf "\n=== MANIFEST ALIRE (alire.toml) ===\n" >> $(CONTEXT_OUT)
	@cat alire.toml >> $(CONTEXT_OUT) 2>/dev/null || true
	@printf "\n=== KONFIGURACJA GPRBUILD (%s) ===\n" "$(GPR_FILE)" >> $(CONTEXT_OUT)
	@cat $(GPR_FILE) >> $(CONTEXT_OUT)
	@printf "\n=== INTERFEJSY I SPECYFIKACJE (.ads) ===\n" >> $(CONTEXT_OUT)
	@find src tests -name "*.ads" -type f | while read f; do \
		printf "\n--- PLIK: %s ---\n" "$$f" >> $(CONTEXT_OUT); \
		cat "$$f" >> $(CONTEXT_OUT); \
	done
	@echo "$(C_GREEN)==> Kontekst spakowany do context.txt.$(C_RESET)"
	@echo "$(C_YELLOW)    następny krok: wklej context.txt do rozmowy z AI$(C_RESET)"

#  =============================================================================
#  META-SEKCJA 4: WYDANIE I WERSJONOWANIE
#  =============================================================================

## bump: Podbija wersję (VERSION + alire.toml.tpl + .cz.toml.tpl) o LEVEL
bump:
	@case "$(LEVEL)" in patch|minor|major) : ;; *) echo "Użycie: make bump LEVEL=patch|minor|major"; exit 1 ;; esac; \
	V=$$(cut -d"+" -f1 < VERSION 2>/dev/null); \
	if [ -z "$$V" ]; then V=0.1.0; fi; \
	MAJ=$$(printf '%s' "$$V" | cut -d. -f1); \
	MIN=$$(printf '%s' "$$V" | cut -d. -f2); \
	PAT=$$(printf '%s' "$$V" | cut -d. -f3); \
	case "$(LEVEL)" in \
		patch) PAT=$$((PAT + 1)) ;; \
		minor) MIN=$$((MIN + 1)); PAT=0 ;; \
		major) MAJ=$$((MAJ + 1)); MIN=0; PAT=0 ;; \
	esac; \
	NV="$$MAJ.$$MIN.$$PAT"; \
	echo "$$NV" > VERSION; \
	if [ -f alire.toml ]; then sed -i 's/^version = .*/version = "'$$NV'"/' alire.toml; fi; \
	if [ -f .cz.toml ]; then sed -i 's/^version = .*/version = "'$$NV'"/' .cz.toml; fi; \
	echo "$(C_GREEN)==> Wersja: $$V -> $$NV$(C_RESET)"
	@echo "$(C_YELLOW)    następny krok: git commit + git tag v<wersja z VERSION>$(C_RESET)"

## package: Pakuje projekt do archiwum ZIP w dist/
package:
	@echo "$(C_BLUE)==> Archiwizacja projektu...$(C_RESET)"
	@mkdir -p dist
	@zip -r dist/$(PROJECT_NAME)_v$(VERSION).zip \
		$(wildcard src tests doc make-templ Makefile alire.toml $(GPR_FILE) \
		README.md ROADMAP.md VERSION LICENSE .gitignore .editorconfig CONTRIBUTING.md)
	@echo "$(C_GREEN)==> Archiwum ZIP gotowe w dist/.$(C_RESET)"
	@echo "$(C_YELLOW)    następny krok: make gh-repo lub wydanie ręczne$(C_RESET)"

#  =============================================================================
#  CELE FIKCYJNE (PHONY)
#  =============================================================================
.PHONY: help workflow wf doctor index-update setup-project git-init gh-repo \
        git-reset build build-release build-prod run run-bin clean syntax format \
        new-module todos test test-alire test-aunit test-gen test-gnattest \
        prove-l1 prove-l2 prove-l3 prove coverage cov show-coverage metrics mt \
        info dump-context ctx bump package
