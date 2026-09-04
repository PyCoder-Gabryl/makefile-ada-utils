# PyCoder Makefile Ada Utils

> Uniwersalny, modułowy framework automatyzacji cyklu wytwórczego dla projektów w języku Ada 2022 / SPARK / Alire.

System orkiestracji oparty na rygorystycznym standardzie kodu (3 spacje wcięcia, limit 120 znaków), w pełni zintegrowany z analizatorem formalnym **SPARK** (poziomy dowodzenia L1–L3), frameworkiem testów jednostkowych **AUnit**, analizą pokrycia kodu **GNATcov** (z terminalowym podglądem TUI w `fzf`), modularnym generatorem zrzutów kontekstu dla modeli sztucznej inteligencji (`dump-txt/`) oraz bezpiecznym przepływem pracy Git dla stanowisk wielomaszynowych.

---

## Wymagania środowiskowe

* **System operacyjny:** macOS (Apple Silicon / Intel), Linux lub Windows (MinGW/MSYS2).
* **Menedżer pakietów:** [Alire](https://alire.ada.dev/) (`alr`) w wersji 1.2+ lub 2.0+.
* **Narzędzia GNU/POSIX:** `make`, `git`, `sed`, `awk`.
* **Opcjonalne (zalecane dla pełnej wygody):**
  * `fzf` — do obsługi pełnoekranowych przeglądarek terminalowych (`make help-all`, `make cov-view`),
  * `gh` — GitHub CLI do automatycznego tworzenia i publikacji repozytoriów.

---

## Scenariusz 1: Tworzenie NOWEGO projektu od zera

### Krok 1: Pobranie szablonu do nowego katalogu
Utwórz nowy katalog projektu w edytorze (np. JetBrains / VS Code) i sklonuj do niego zawartość szablonu:

```bash
git clone git@github.com:PyCoder-Gabryl/makefile-ada-utils.git .
```
*(Alternatywnie użyj zielonego przycisku **"Use this template"** bezpośrednio na GitHubie).*

---

### Krok 2: Uruchomienie kreatora inicjalizacji (Magiczne polecenie)
W oknie terminala wewnątrz nowego folderu uruchom:

```bash
make init-all
```

> **Wskazówka:** Możesz od razu podać nazwę projektu w linii poleceń:  
> `make init-all NAME=twoj_projekt`

Kreator przeprowadzi Cię przez konfigurację:
1. **Nazwa skrzynki Alire / pliku binarnego** (np. `kalkulator`),
2. **Nazwa projektu GNAT / jednostki Ada** (np. `Kalkulator`),
3. **Dane autora** (imię, e-mail, login GitHub).

#### Co system wykona w pełni automatycznie:
* Wygeneruje strukturę katalogów (`src/`, `tests/`, `data/config/`, `doc/`, `bin/`, `obj/`),
* Utworzy plik projektu GNAT (`<nazwa>.gpr`) z rygorystycznymi flagami Ada 2022 i SPARK,
* Przygotuje manifest `alire.toml` oraz szablony metadanych (`VERSION`, `ROADMAP.md`),
* Wdroży działającą od pierwszej sekundy uprząż testów AUnit (`tests/test_runner.adb`),
* Zainstaluje 3 strażnicze hooki Git (`commit-msg`, `post-commit`, `pre-push`),
* Zainicjuje lokalne repozytorium Git z gałęzią `main` i wyśle powitalny commit na Twój GitHub.

---

### Krok 3: Weryfikacja sprawności środowiska (Sanity Check)

```bash
make check && make test-all
```

---

### Krok 4: Pierwsza kompilacja i uruchomienie

```bash
make build && make run-bin
```

---

## Scenariusz 2: Aktualizacja ISTNIEJĄCEGO projektu w Adzie

Aby wdrożyć nowoczesny silnik Make do wcześniej utworzonego projektu w Adzie bez naruszania istniejącego kodu źródłowego (`src/`) ani konfiguracji:

1. Będąc w katalogu swojego istniejącego projektu, skopiuj z tego repozytorium plik `Makefile` oraz folder `make-tools/`:
```bash
cp /sciezka/do/makefile-ada-utils/Makefile .
rm -rf make-tools && cp -r /sciezka/do/makefile-ada-utils/make-tools .
```
2. Zainstaluj nowoczesne hooki Git:
```bash
make git-init
```
3. Zweryfikuj projekt:
```bash
make check
```

---

## Katalog poleceń w codziennej pracy

### 1. Budowanie, czyszczenie i uruchamianie
* `make build` — szybka kompilacja deweloperska (`-O0`, asercje `-gnata`, symbole debuggera `-g`)
* `make build-release` — zrównoważona kompilacja produkcyjna (`-O2`, inlining `-gnatn`)
* `make run-bin` — bezpośrednie uruchomienie pliku wykonywalnego z katalogu `bin/`
* `make run` — uruchomienie programu przez menedżer Alire
* `make rebuild` — czysta rekompilacja (`clean` -> `build`)
* `make clean` — usunięcie obiektów, binariów, śladów i raportów
* `make clean-logs` — usunięcie plików dziennika i katalogu `logs/`
* `make clean-all` — gruntowne czyszczenie deweloperskie (z zachowaniem skrzynki `alire/`)

### 2. Testy, dowodzenie formalne SPARK i pokrycie kodu
* `make test-aunit` — kompilacja i bieg testów jednostkowych AUnit
* `make test-all` — pełna weryfikacja automatyczna (`test-aunit` -> `prove-l1`)
* `make prove-l1` — analiza przepływu danych i zmiennych globalnych (SPARK Poziom 1)
* `make prove-l2` — matematyczny dowód braku błędów wykonania AoRTE (SPARK Poziom 2)
* `make prove-l3` — weryfikacja poprawności kontraktów `Pre`/`Post` (SPARK Poziom 3)
* `make coverage` — generowanie śladu wykonania i raportu pokrycia GNATcov
* `make cov-view` — pełnoekranowa przeglądarka TUI raportów pokrycia `.xcov` w `fzf`

### 3. Git Workflow dla stanowisk wielomaszynowych
* `make git-getsync` — bezpieczna synchronizacja liniowa z GitHubem (`pull --rebase`)
* `make git-branch` — utworzenie nowej gałęzi roboczej z interaktywnym dialogiem
* `make git-push-inprogress` — awaryjne wysłanie kodu roboczego na GitHub z pominięciem testów (`--no-verify`)
* `make git-status` (`gs`) — zwięzły stan repozytorium z objaśniającą legendą oznaczeń
* `make git-log` (`gl`) — kompaktowe drzewo ostatnich commitów w grafice ASCII
* `make git-workhelp` — obszerny samouczek pracy z Git i GitHubem w projekcie

### 4. Modularne zrzuty kontekstu dla modeli AI (`dump-txt/`)
* `make dump-src` — wyizolowany zrzut kodu źródłowego (`src/**/*.ad[sb]`) do `dump-txt/src.txt`
* `make dump-data` — zrzut zasobów, konfiguracji TOML i schematów do `dump-txt/data.txt`
* `make dump-src-data` — zrzut łączący kod i zasoby w `dump-txt/src-data.txt`
* `make dump-tree` / `make dump-tree-dir` — zrzut struktury plików/katalogów bez szumu obiektowego
* `make dump-full` — kompletny, scalony audyt projektu w `dump-txt/00-full.txt`
* `make dump-clean` — usunięcie wygenerowanych zrzutów z folderu `dump-txt/`

### 5. Dokumentacja i diagnostyka
* `make help` — drzewiasta mapa wszystkich dostępnych celów Make
* `make help-all` — interaktywna przeglądarka TUI całej dokumentacji w `fzf`
* `make help-all-paged` — ciągły, stronicowany wydruk dokumentacji przez pager (`less -RFX`)
* `make workflow` (`wf`) — opisowy przewodnik po cyklu deweloperskim
* `make doctor` — diagnostyka obecności i ścieżek narzędzi Alire i systemowych
* `make syntax` — szybka kontrola poprawności semantycznej Ada 2022 (`gnatc`)
* `make format` — automatyczne formatowanie kodu źródłowego (`gnatpp` standard 3 spacji)
* `make metrics` (`mt`) — pomiar złożoności cyklomatycznej McCabe'a i linii SPARK

---

## Konwencja commitów

W repozytoriach opartych na tym frameworku obowiązuje standard *Conventional Commits* z wymuszaniem prefiksów przez hook `commit-msg`:

`add:`, `fix:`, `docs:`, `test:`, `refactor:`, `style:`, `perf:`, `build:`, `ci:`, `chore:`, `revert:`, `release:`, `bump:`

---

## Autor i licencja

**PyCoder Gabryl**  
GitHub: [PyCoder-Gabryl](https://github.com/PyCoder-Gabryl/)  
E-mail: pycoder.gabryl@gmail.com  
Licencja: [Apache License 2.0](LICENSE)
