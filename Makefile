#  =============================================================================
#  PROJECT:          Makefile Ada Utils
#  AUTHOR:           PyCoder Gabryl
#  EMAIL:            pycoder.gabryl@gmail.com
#  GITHUB:           https://github.com/PyCoder-Gabryl/
#  LICENSE:          Apache License 2.0
#  -----------------------------------------------------------------------------
#  DESCRIPTION:      Główny plik Makefile (cienki wrapper).
#                    Ładuje konfigurację, makro bannera i moduły z make-tools/.
#  -----------------------------------------------------------------------------
#  PATH:             Makefile
#  CREATED:          2026-07-07
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

GPR_FILE       ?= $(firstword $(filter-out gnatcov_rts.gpr,$(wildcard *.gpr)))
PROJECT_NAME   ?= $(basename $(notdir $(GPR_FILE)))
EXE_NAME       ?= $(PROJECT_NAME)
NAME           ?=
GPR_NAME       ?=
REPO_NAME      ?=
MAKE_TOOLS_DIR ?= $(CURDIR)/make-tools
SRC_SUBDIRS    ?= config core i18n logging app driver ui

# Domyślne dane twórcy dla nowych projektów (można nadpisać w linii poleceń)
AUTHOR         ?= PyCoder Gabryl
EMAIL          ?= pycoder.gabryl@gmail.com
GITHUB_USER    ?= PyCoder-Gabryl
GITHUB_URL     ?= https://github.com/$(GITHUB_USER)

TEST_GPR       := tests/tests.gpr
TEST_RUNNER    := tests/bin/test_runner
HARNESS_DIR    := tests/harness
HARNESS_GPR    := $(HARNESS_DIR)/test_driver.gpr
HARNESS_BIN    := $(HARNESS_DIR)/test_runner
GEN_TESTS_DIR  := tests/gen

VERSION        := $(shell cat VERSION 2>/dev/null || echo "0.1.0")
COV_REPORT     := coverage_report
COV_RTS_DIR    := $(CURDIR)/gnatcov_rts
COV_LEVEL      := stmt+decision
PROVE_TIMEOUT  ?= 30
REPO_VISIBILITY ?= private
LEVEL          ?= patch
DIR            ?= core

RM             := rm -rf

export LANG    := pl_PL.UTF-8
export LC_ALL  := pl_PL.UTF-8
export PATH    := $(shell echo $$HOME)/.alire/bin:$(PATH)

#  =============================================================================
#  MAKRO BANNERA KONSOLOWEGO
#  =============================================================================
define print_banner
	@if [ -z "$$BANNER_SHOWN" ]; then \
		printf "$(C_CYAN)╔══════════════════════════════════════════════════════════════════════╗\n"; \
		printf "║           PyCoder Makefile Ada Utils  v. 1.0.0 – A.D.2026            ║\n"; \
		printf "╚══════════════════════════════════════════════════════════════════════╝$(C_RESET)\n"; \
		printf "$(C_GREEN)RUN:$(C_RESET) $(C_BLUE)%s$(C_RESET)\n\n" "$1"; \
		export BANNER_SHOWN=1; \
	fi
endef

#  =============================================================================
#  ŁADOWANIE MODUŁÓW
#  =============================================================================
include $(MAKE_TOOLS_DIR)/modules/01-init.mk
include $(MAKE_TOOLS_DIR)/modules/02-build.mk
include $(MAKE_TOOLS_DIR)/modules/03-test.mk
include $(MAKE_TOOLS_DIR)/modules/04-utils.mk
include $(MAKE_TOOLS_DIR)/modules/05-git.mk

#  =============================================================================
#  POMOC GŁÓWNA I WORKFLOW
#  =============================================================================

## help: Wyświetla pełną listę poleceń z podziałem na grupy i polecenia zbiorcze
help:
	$(call print_banner,make help)
	@echo "$(C_BLUE)======================================================================$(C_RESET)"
	@echo "$(C_BLUE)         $(PROJECT_NAME) - CENTRUM AUTOMATYZACJI (Modułowe)            $(C_RESET)"
	@echo "$(C_BLUE)======================================================================$(C_RESET)"
	@echo "$(C_YELLOW)--- [1] INICJACJA PROJEKTU ---$(C_RESET)"
	@echo "  $(C_GREEN)make init-all$(C_RESET)        - Pełny setup (projekt -> git -> github)"
	@echo "    ├─ setup-project   - Inicjalizuje projekt (alr init + szablony)"
	@echo "    ├─ git-init        - Tworzy repozytorium Git i instaluje hooki"
	@echo "    └─ gh-repo         - Tworzy repozytorium na GitHubie (SSH)"
	@echo "  make git-reset       - Usuwa .git i cofa wersję (wymaga CONFIRM=1)"
	@echo ""
	@echo "$(C_YELLOW)--- [2] BUDOWANIE, CZYSZCZENIE I URUCHAMIANIE ---$(C_RESET)"
	@echo "  $(C_GREEN)make rebuild$(C_RESET)         - Czysta kompilacja (clean -> build)"
	@echo "    ├─ clean           - Usuwa pliki obiektowe, raporty testów i artefakty"
	@echo "    └─ build           - Buduje projekt w trybie deweloperskim (debug)"
	@echo "  make build-release   - Budowanie produkcyjne z optymalizacją (-O2)"
	@echo "  make run             - Uruchamia program przez środowisko Alire"
	@echo "  make run-bin         - Uruchamia zbudowaną binarkę bezpośrednio z bin/"
	@echo "  make clean-logs      - Usuwa pliki dziennika i katalog logs/"
	@echo "  make clean-dump      - Usuwa wygenerowane zrzuty z katalogu dump-txt/"
	@echo "  make clean-all       - Gruntowne czyszczenie (artefakty, zrzuty, config/)"
	@echo ""
	@echo "$(C_YELLOW)--- [3] TESTY, DOWODY SPARK I POKRYCIE KODU ---$(C_RESET)"
	@echo "  $(C_GREEN)make test-all$(C_RESET)        - Pełna weryfikacja automatyczna (testy -> dowody)"
	@echo "    ├─ test-aunit      - Kompiluje i uruchamia testy jednostkowe AUnit"
	@echo "    └─ prove-l1        - SPARK: Analiza przepływu danych (Poziom 1)"
	@echo "  make test            - Uruchamia testy zdefiniowane w alire.toml"
	@echo "  make prove-l2        - SPARK: Dowód braku błędów wykonania (AoRTE)"
	@echo "  make prove-l3        - SPARK: Weryfikacja kontraktów Pre/Post"
	@echo "  make coverage        - Generuje ślad i raport pokrycia kodu (GNATcov)"
	@echo "  make coverage-summary- Tabela podsumowująca procentowe pokrycie kodu"
	@echo "  make show-coverage   - Pełnoekranowa przeglądarka TUI raportów (.xcov)"
	@echo "                         (Alias: make cov-view)"
	@echo ""
	@echo "$(C_YELLOW)--- [4] NARZĘDZIA, DIAGNOSTYKA I ZRZUTY KONTEKSTU ---$(C_RESET)"
	@echo "  $(C_GREEN)make check$(C_RESET)           - Szybki przegląd kodu (doctor -> syntax -> format)"
	@echo "    ├─ doctor          - Diagnostyka środowiska (wykrywa narzędzia)"
	@echo "    ├─ syntax          - Szybkie sprawdzenie semantyki (gnatc)"
	@echo "    └─ format          - Automatyczne formatowanie kodu (gnatpp)"
	@echo "  make metrics (mt)    - Analizuje złożoność cyklomatyczną (gnatmetric)"
	@echo "  make help-dump       - Ekran pomocy dedykowany systemowi zrzutów kontekstu"
	@echo "  make dump-full       - Kompletny zrzut projektu do dump-txt/00-full.txt"
	@echo "  make bump LEVEL=x    - Podbija numer wersji (patch/minor/major)"
	@echo ""
	@echo "$(C_YELLOW)--- [5] CODZIENNY PRZEPŁYW PRACY Z GIT (WSPÓŁPRACA) ---$(C_RESET)"
	@echo "  make git-getsync     - Bezpieczne pobranie zmian z GitHuba (pull --rebase)"
	@echo "  make git-branch      - Tworzy nową gałąź roboczą (pyta o nazwę, jeśli brak)"
	@echo "  make git-push-inprogress - Wypchnięcie stanu roboczego bez testów (--no-verify)"
	@echo "  make git-status (gs) - Zwięzły stan repozytorium z objaśnieniem oznaczeń"
	@echo "  make git-log (gl)    - Drzewo ostatnich commitów w grafice ASCII"
	@echo "  make git-workhelp    - Obszerny samouczek pracy z Git i GitHubem w projekcie"
	@echo ""
	@echo "$(C_CYAN)make help-all$(C_RESET)        - Interaktywna przeglądarka TUI całej pomocy w fzf"
	@echo "$(C_CYAN)make help-all-paged$(C_RESET)  - Stronicowany wydruk całej pomocy przez pager (less -RFX)"
	@echo "$(C_CYAN)make workflow (wf)$(C_RESET)    - Przewodnik po cyklu życia projektu (opisowy)"

## help-all: Interaktywna przeglądarka całej dokumentacji w fzf (TUI)
help-all:
	$(call print_banner,make help-all)
	@if command -v fzf >/dev/null 2>&1; then \
		printf "%s\n" \
			"1. Mapa ogólna poleceń       (make help)" \
			"2. Inicjacja projektu         (make help-init)" \
			"3. Budowanie i czyszczenie   (make help-build)" \
			"4. Testy i dowody SPARK      (make help-test)" \
			"5. Narzędzia i diagnostyka   (make help-utils)" \
			"6. Zrzuty kontekstu          (make help-dump)" \
			"7. Codzienna praca z Git     (make help-git)" \
			"8. Przewodnik cyklu życia    (make workflow)" \
		| fzf --ansi --prompt="Sekcja pomocy > " \
			--height=100% --reverse \
			--header="Wybierz sekcję strzałkami | ESC: wyjście" \
			--preview-window=right:70%:wrap \
			--preview 'case {} in \
				*1.*) $(MAKE) --no-print-directory BANNER_SHOWN=1 help ;; \
				*2.*) $(MAKE) --no-print-directory BANNER_SHOWN=1 help-init ;; \
				*3.*) $(MAKE) --no-print-directory BANNER_SHOWN=1 help-build ;; \
				*4.*) $(MAKE) --no-print-directory BANNER_SHOWN=1 help-test ;; \
				*5.*) $(MAKE) --no-print-directory BANNER_SHOWN=1 help-utils ;; \
				*6.*) $(MAKE) --no-print-directory BANNER_SHOWN=1 help-dump ;; \
				*7.*) $(MAKE) --no-print-directory BANNER_SHOWN=1 help-git ;; \
				*8.*) $(MAKE) --no-print-directory BANNER_SHOWN=1 workflow ;; \
			esac' || true; \
	else \
		$(MAKE) --no-print-directory help-all-paged; \
	fi

## help-all-paged: Ciągły, stronicowany wydruk całej pomocy przez pager (less -RFX)
help-all-paged:
	@PAGER_CMD="cat"; \
	if [ -t 1 ] && command -v less >/dev/null 2>&1; then \
		PAGER_CMD="less -RFX"; \
	fi; \
	( \
		$(MAKE) --no-print-directory BANNER_SHOWN=1 help; \
		echo ""; \
		$(MAKE) --no-print-directory BANNER_SHOWN=1 help-init; \
		echo ""; \
		$(MAKE) --no-print-directory BANNER_SHOWN=1 help-build; \
		echo ""; \
		$(MAKE) --no-print-directory BANNER_SHOWN=1 help-test; \
		echo ""; \
		$(MAKE) --no-print-directory BANNER_SHOWN=1 help-utils; \
		echo ""; \
		$(MAKE) --no-print-directory BANNER_SHOWN=1 help-dump; \
		echo ""; \
		$(MAKE) --no-print-directory BANNER_SHOWN=1 help-git; \
		echo ""; \
		$(MAKE) --no-print-directory BANNER_SHOWN=1 workflow; \
	) | $$PAGER_CMD

## workflow: Przewodnik po cyklu deweloperskim - 4 metasekcje (Alias: wf)
workflow wf:
	$(call print_banner,make workflow)
	@echo "$(C_BLUE)======================================================================$(C_RESET)"
	@echo "$(C_BLUE)  PRZEWODNIK PO CYKLU ŻYCIA PROJEKTU ($(PROJECT_NAME)) - 4 METASEKCJE$(C_RESET)"
	@echo "$(C_BLUE)======================================================================$(C_RESET)"
	@echo "$(C_GREEN)[1/4] INICJACJA I SYNCHRONIZACJA$(C_RESET)"
	@echo "  make init-all                 - PEŁNY SETUP: setup-project -> git-init -> gh-repo"
	@echo "  make git-getsync              - start na drugim komputerze: pobierz stan (rebase)"
	@echo "  make git-branch [NAME=x]      - zacznij nową funkcjonalność na bezpiecznej gałęzi"
	@echo ""
	@echo "$(C_GREEN)[2/4] CODZIENNA PRACA$(C_RESET)"
	@echo "  make rebuild                  - CZYSTA KOMPILACJA: clean -> build"
	@echo "  make run / run-bin            - uruchomienie przez alr / binarki z bin/"
	@echo "  make git-push-inprogress      - wyślij kod roboczy na GitHub bez testów"
	@echo "  make clean / clean-all        - codzienne / gruntowne sprzątanie artefaktów"
	@echo "  make clean-logs               - usunięcie logów diagnostycznych"
	@echo ""
	@echo "$(C_GREEN)[3/4] TESTY, DOWODY I POKRYCIE KODU$(C_RESET)"
	@echo "  make test-all                 - PEŁNA WERYFIKACJA: test-aunit -> prove-l1"
	@echo "  make test-aunit               - nasza uprząż AUnit (tests/tests.gpr)"
	@echo "  make prove-l1 / l2 / l3       - dowody formalne SPARK (rosnąco)"
	@echo "  make coverage (cov)           - pokrycie kodu GNATcov (ślad i podsumowanie)"
	@echo "  make cov-view                 - pełnoekranowa przeglądarka TUI raportów .xcov"
	@echo ""
	@echo "$(C_GREEN)[4/4] NARZĘDZIA, DIAGNOSTYKA I ZRZUTY DLA AI$(C_RESET)"
	@echo "  make check                    - SZYBKI PRZEGLĄD: doctor -> syntax -> format"
	@echo "  make doctor                   - raport: narzędzia OK/BRAK + wykryte ścieżki"
	@echo "  make syntax                   - szybka kontrola semantyki (gnatc)"
	@echo "  make format                   - formatowanie kodu źródłowego (gnatpp)"
	@echo "  make metrics (mt)             - złożoność cyklomatyczna (gnatmetric)"
	@echo "  make help-dump                - pomoc dla modularnych zrzutów w dump-txt/"
	@echo "  make dump-full                - kompletny zrzut projektu do dump-txt/00-full.txt"
	@echo "  make bump LEVEL=patch|minor   - podbicie VERSION + alire.toml"
	@echo ""
	@echo "$(C_YELLOW)Konwencja feedbacku: każdy target kończy się linią '==>' (co zrobione)$(C_RESET)"

.PHONY: help help-all help-all-paged workflow wf
