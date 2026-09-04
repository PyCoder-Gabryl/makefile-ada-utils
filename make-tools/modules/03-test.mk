# ============================================================================
# PROJECT:         Makefile System
# AUTHOR:          PyCoder Gabryl
# GITHUB:          https://github.com/PyCoder-Gabryl
# EMAIL:           pycoder.gabryl@gmail.com
# LICENSE:         Apache 2.0
# ----------------------------------------------------------------------------
# DESCRIPTION:     Moduł testów jednostkowych i analizy formalnej SPARK.
#                  Zarządza uprzężą AUnit, dowodzeniem formalnym na poziomach
#                  L1-L3, analizą pokrycia kodu GNATcov oraz interaktywną
#                  przeglądarką wyników TUI opartą o fzf z legendą metryk.
# ----------------------------------------------------------------------------
# PATH:            make-tools/modules/03-test.mk
# CREATED:         2026-09-04
# ============================================================================

## help-test: Pomoc dla sekcji testów i dowodów
help-test:
	@echo "$(C_BLUE)--- GRUPA: TESTY I DOWODY SPARK ---$(C_RESET)"
	@echo "  make test-aunit       - Kompiluje i uruchamia testy jednostkowe AUnit"
	@echo "  make test             - Uruchamia testy skonfigurowane w alire.toml"
	@echo "  make prove-l1         - SPARK: Analiza przepływu danych (Data Flow)"
	@echo "  make prove-l2         - SPARK: Dowód braku błędów czasu wykonania (AoRTE)"
	@echo "  make prove-l3         - SPARK: Dowód spełnienia kontraktów (Pre/Post)"
	@echo "  make coverage         - Generuje raport pokrycia kodu testami (GNATcov)"
	@echo "  make coverage-summary - Tabela podsumowująca procentowe pokrycie kodu"
	@echo "  make show-coverage    - Pełnoekranowa przeglądarka TUI raportów (.xcov)"
	@echo "                          (Alias: make cov-view)"
	@echo "  $(C_GREEN)make test-all$(C_RESET)         - Pełna weryfikacja automatyczna (test-aunit -> prove-l1)"

## test-all: Pełna weryfikacja (testy -> dowody)
test-all:
	$(call print_banner,make test-all)
	@$(MAKE) --no-print-directory test-aunit
	@$(MAKE) --no-print-directory prove-l1

## test: Uruchamia testy Alire
test test-alire:
	@echo "$(C_BLUE)==> Uruchamianie testów zdefiniowanych w Alire...$(C_RESET)"
	@alr test

## test-aunit: Kompiluje i uruchamia własną uprząż AUnit
test-aunit:
	@echo "$(C_BLUE)==> Kompilacja i uruchomienie testów AUnit...$(C_RESET)"
	@if [ ! -f tests/test_runner.adb ]; then \
		echo "$(C_RED)Błąd: Brak pliku źródłowego tests/test_runner.adb$(C_RESET)"; \
		exit 1; \
	fi
	@echo "    Projekt uprzęży testowej: $(TEST_GPR)"
	@alr exec gprbuild -- -p -P $(TEST_GPR) -j0
	@echo "    Wykonywanie testów jednostkowych ($(TEST_RUNNER))..."
	@$(TEST_RUNNER)
	@echo "$(C_GREEN)==> Wszystkie asercje AUnit wykonane pomyślnie.$(C_RESET)"

## prove-l1: Analiza przepływu danych (Poziom 1)
prove-l1:
	@echo "$(C_BLUE)==> SPARK: Analiza przepływu danych (Poziom 1 - Data Flow)...$(C_RESET)"
	@echo "    Weryfikacja braku niezainicjalizowanych zmiennych i kontraktów Global"
	@alr exec gnatprove -- -P $(GPR_FILE) --level=1 -XSPARK_MODE=On --timeout=$(PROVE_TIMEOUT)
	@echo "$(C_GREEN)==> Analiza przepływu danych SPARK (L1) zakończona sukcesem.$(C_RESET)"

## prove-l2: Dowód braku błędów wykonania (Poziom 2)
prove-l2 prove:
	@echo "$(C_BLUE)==> SPARK: Dowód braku błędów wykonania (Poziom 2 - AoRTE)...$(C_RESET)"
	@echo "    Matematyczny dowód braku przepełnień buforów i naruszeń zakresów"
	@alr exec gnatprove -- -P $(GPR_FILE) --level=2 -XSPARK_MODE=On --timeout=$(PROVE_TIMEOUT)
	@echo "$(C_GREEN)==> Dowód braku błędów wykonania SPARK (L2) zakończony sukcesem.$(C_RESET)"

## prove-l3: Dowód poprawności kontraktów Pre/Post (Poziom 3)
prove-l3:
	@echo "$(C_BLUE)==> SPARK: Weryfikacja kontraktów funkcyjnych (Poziom 3 - Pre/Post)...$(C_RESET)"
	@echo "    Dowodzenie zgodności kodu z formalną specyfikacją kontraktów"
	@alr exec gnatprove -- -P $(GPR_FILE) --level=3 -XSPARK_MODE=On --timeout=$(PROVE_TIMEOUT)
	@echo "$(C_GREEN)==> Dowód kontraktów SPARK (L3) zakończony sukcesem.$(C_RESET)"

## coverage: Generuje raport pokrycia kodu testami (GNATcov, XCOV)
coverage cov: clean
	@echo "$(C_BLUE)==> Analiza pokrycia kodu testami (GNATcov)...$(C_RESET)"
	@echo "    [1/4] Inicjalizacja biblioteki uruchomieniowej GNATcov RTS..."
	@alr exec -- gnatcov setup --prefix=$(COV_RTS_DIR)
	@echo "    [2/4] Instrumentacja źródeł projektu $(PROJECT_NAME)..."
	@alr exec -- sh -c '\
		GPR_PROJECT_PATH="$(COV_RTS_DIR)/share/gpr:$$GPR_PROJECT_PATH" \
		gnatcov instrument -P $(GPR_FILE) --level=$(COV_LEVEL) \
		--projects=$(PROJECT_NAME)'
	@echo "    [3/4] Kompilacja binarki ze śledzeniem pokrycia..."
	@alr exec -- sh -c '\
		GPR_PROJECT_PATH="$(COV_RTS_DIR)/share/gpr:$$GPR_PROJECT_PATH" \
		gprbuild -P $(GPR_FILE) -j0 --src-subdirs=gnatcov-instr \
		--implicit-with=gnatcov_rts.gpr'
	@echo "    [4/4] Bieg programu i zbieranie śladu wykonania..."
	@alr exec -- sh -c 'GNATCOV_TRACE_FILE=$(PROJECT_NAME).trace ./bin/$(EXE_NAME)'
	@mkdir -p $(COV_REPORT)
	@alr exec -- sh -c '\
		gnatcov coverage -P $(GPR_FILE) --level=$(COV_LEVEL) \
		--annotate=xcov --output-dir=$(COV_REPORT) $(PROJECT_NAME).trace'
	@echo "$(C_GREEN)==> Raport pokrycia wygenerowany w katalogu $(COV_REPORT)/.$(C_RESET)"
	@$(MAKE) --no-print-directory coverage-summary

## coverage-summary: Wyświetla tabelaryczne podsumowanie procentowe pokrycia kodu
coverage-summary cov-sum:
	@if [ ! -d $(COV_REPORT) ]; then \
		echo "$(C_RED)Błąd: Katalog $(COV_REPORT) nie istnieje. Najpierw: make coverage$(C_RESET)"; \
		exit 1; \
	fi
	@echo ""
	@echo "$(C_BLUE)======================================================================$(C_RESET)"
	@echo "$(C_BLUE)              PODSUMOWANIE POKRYCIA KODU (GNATcov)                    $(C_RESET)"
	@echo "$(C_BLUE)======================================================================$(C_RESET)"
	@printf "  %-32s %8s %8s %10s\n" "PLIK ŹRÓDŁOWY" "    POKRYTE" "	BRAK" "	POKRYCIE"
	@echo "  ------------------------------------------------------------------"
	@for f in $(COV_REPORT)/*.xcov; do \
		[ -f "$$f" ] || continue; \
		base=$$(basename "$$f" .xcov); \
		cov=$$(awk '$$2 ~ /^\+:/ {c++} END {print c+0}' "$$f"); \
		uncov=$$(awk '$$2 ~ /^[-!]:/ {c++} END {print c+0}' "$$f"); \
		total=$$((cov + uncov)); \
		if [ $$total -gt 0 ]; then \
			pct=$$((cov * 100 / total)); \
			if [ $$pct -eq 100 ]; then col="$(C_GREEN)"; \
			elif [ $$pct -ge 50 ]; then col="$(C_YELLOW)"; \
			else col="$(C_RED)"; fi; \
			printf "  %-32s %8d %8d $${col}%9d%%$(C_RESET)\n" \
				"$$base" "$$cov" "$$uncov" "$$pct"; \
		else \
			printf "  %-32s %8s %8s %10s\n" "$$base" "-" "-" "brak kodu"; \
		fi; \
	done
	@echo "  ------------------------------------------------------------------"
	@echo "  \033[90mLegenda metryk:\033[0m"
	@echo "  \033[90m• POKRYTE   - instrukcje wykonane przynajmniej raz (+:)\033[0m"
	@echo "  \033[90m• BRAK      - instrukcje nieuruchomione w teście (-:, !:)\033[0m"
	@echo "  \033[90m• brak kodu - pliki specyfikacji (.ads) bez kodu maszynowego\033[0m"
	@echo "  ------------------------------------------------------------------"
	@echo "$(C_YELLOW)Szczegółowy podgląd TUI: make show-coverage (lub make cov-view)$(C_RESET)"
	@echo ""

## show-coverage: Pełnoekranowa przeglądarka TUI raportów pokrycia kodu (.xcov)
show-coverage cov-view:
	@if [ ! -d $(COV_REPORT) ]; then \
		echo "$(C_RED)Błąd: Katalog $(COV_REPORT) nie istnieje. Najpierw: make coverage$(C_RESET)"; \
		exit 1; \
	fi
	@if command -v fzf >/dev/null 2>&1; then \
		echo "$(C_BLUE)==> Uruchamianie terminalowej przeglądarki pokrycia kodu...$(C_RESET)"; \
		(cd $(COV_REPORT) && fzf --prompt="Plik raportu > " \
			--height=100% \
			--reverse \
			--header="Strzałki: góra/dół | ESC: wyjście | (+) zielony, (-) czerwony" \
			--preview-window=right:70%:wrap \
			--preview 'awk '\''$$2 ~ /^\+:/ {print "\033[32m" $$0 "\033[0m"} \
				$$2 ~ /^[-!]:/ {print "\033[31;1m" $$0 "\033[0m"} \
				$$2 ~ /^\.:/ {print "\033[90m" $$0 "\033[0m"} \
				$$2 !~ /^[\+\-\!\.]/ {print $$0}'\'' {}' \
		) || true; \
		$(MAKE) --no-print-directory coverage-summary; \
	else \
		echo "$(C_YELLOW)Wskazówka: Zainstaluj fzf ('brew install fzf'), aby uzyskać TUI.$(C_RESET)"; \
		if [ "$$(uname -s)" = "Darwin" ]; then open $(COV_REPORT); else xdg-open $(COV_REPORT); fi; \
	fi

.PHONY: help-test test-all test test-alire test-aunit prove-l1 prove-l2 prove prove-l3 \
        coverage cov coverage-summary cov-sum show-coverage cov-view
