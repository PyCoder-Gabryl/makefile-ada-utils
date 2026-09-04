# PyCoder Makefile Ada Utils

> Uniwersalny, modułowy framework automatyzacji cyklu wytwórczego dla projektów w języku **Ada 2022** / **SPARK** / **Alire**.

System orkiestracji oparty na rygorystycznym standardzie kodu (3 spacje wcięcia, limit 120 znaków), w pełni zintegrowany z analizatorem formalnym **SPARK** (poziomy dowodzenia L1–L3), frameworkiem testów jednostkowych **AUnit**, analizą pokrycia kodu **GNATcov** (z terminalowym TUI w `fzf`), modularnym generatorem zrzutów kontekstu dla modeli sztucznej inteligencji (`dump-txt/`) oraz bezpiecznym przepływem pracy Git dla stanowisk wielomaszynowych.

---

## Wymagania środowiskowe

* **System operacyjny:** macOS (Apple Silicon / Intel), Linux lub Windows (MinGW/MSYS2).
* **Menedżer pakietów:** [Alire](https://alire.ada.dev/) (`alr`) w wersji 1.2+ lub 2.0+.
* **Narzędzia GNU/POSIX:** `make`, `git`, `sed`, `awk`.
* **Opcjonalne (zalecane):** 
  * `fzf` — do obsługi pełnoekranowych przeglądarek terminalowych (`make help-all`, `make cov-view`),
  * `gh` — GitHub CLI do automatycznego tworzenia i publikacji repozytoriów.

---

## Scenariusz 1: Tworzenie NOWEGO projektu od zera

### Krok 1: Pobranie szablonu do nowego katalogu
Utwórz nowy katalog projektu w edytorze (np. JetBrains / VS Code) i sklonuj do niego zawartość szablonu:
```bash
git clone git@github.com:PyCoder-Gabryl/makefile-ada-utils.git .
