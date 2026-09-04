# Conventional Commits & Semantic Versioning (SemVer)

**Conventional Commits** to ogólnoświatowy standard formatowania wiadomości w systemie kontroli wersji Git. Pozwala na automatyczne generowanie rejestru zmian
(*Changelog*) oraz bezobsługowe wyliczanie numeru wersji projektu zgodnie ze standardem **Semantic Versioning (SemVer)**.

---

## 1. Budowa wiadomości commitu

Składnia pojedynczej wiadomości wygląda następująco:

```text
<typ>(<opcjonalny_zakres>): <krótki_opis_zmiany>

[opcjonalna_treść_rozwinięcia]

[opcjonalna_stopka]
```

### Przykłady:

* `feat: dodanie parsera plików TOML`
* `fix(logger): naprawa dławienia logów w trybie multi-threading`
* `docs: aktualizacja instrukcji instalacji w README`
* `feat!: zmiana architektury API modułu sterowania` *(Breaking Change)*

---

## 2. Tabela typów commitów i ich wpływ na wersję (SemVer)

Standard **SemVer** zapisujemy w formacie **`MAJOR.MINOR.PATCH`** (w naszym projekcie z metadanymi Gita: `MAJOR.MINOR.PATCH+git.<hash>`).

### Podstawowe typy (Standardowe):

| Typ commitu              | Nazwa pełna              | Opis zastosowania                                                                                        | Wpływ na SemVer                |
|:-------------------------|:-------------------------|:---------------------------------------------------------------------------------------------------------|:-------------------------------|
| **`feat`**               | *Feature*                | Dodanie nowej funkcjonalności dla użytkownika / systemu.                                                 | **MINOR** (`0.1.0` -> `0.2.0`) |
| **`fix`**                | *Bug Fix*                | Naprawa istniejącego błędu w kodzie źródłowym.                                                           | **PATCH** (`0.1.0` -> `0.1.1`) |
| **`feat!`** / **`fix!`** | *Breaking Change*        | Zmiana wycofująca wsteczną kompatybilność (wymaga użycia wykrzyknika`!`).                                | **MAJOR** (`0.1.0` -> `1.0.0`) |
| **`docs`**               | *Documentation*          | Modyfikacja dokumentacji (README, docstringi, pliki`.md`).                                               | Brak zmiany wersji             |
| **`style`**              | *Formatting*             | Zmiany formatowania (spacje, wcięcia, autopep8/Black) – bez wpływu na logikę.                            | Brak zmiany wersji             |
| **`refactor`**           | *Refactoring*            | Przebudowa struktury kodu bez zmiany jego działania i bez naprawy błędów.                                | Brak zmiany wersji             |
| **`perf`**               | *Performance*            | Zmiana zoptymalizowana pod kątem wydajności (np. wektoryzacja NumPy, redukcja alokacji).                 | Brak zmiany wersji             |
| **`test`**               | *Testing*                | Dodanie brakujących testów jednostkowych lub ich poprawa.                                                | Brak zmiany wersji             |
| **`build`**              | *Build System*           | Zmiany w systemie budowania lub zewnętrznych zależnościach (`alire.toml.tpl`, `../../Makefile`, `pyproject.toml`). | Brak zmiany wersji             |
| **`ci`**                 | *Continuous Integration* | Zmiany w skryptach automatyzacji CI/CD (np. GitHub Actions).                                             | Brak zmiany wersji             |
| **`chore`**              | *Chore*                  | Rutynowe prace porządkowe nieprzystające do innych typów (np. zmiana`.gitignore.tpl`).                       | Brak zmiany wersji             |

### Dodatkowe popularne typy rozszerzone:

| Typ commitu                | Nazwa pełna        | Opis zastosowania                                                                                  | Wpływ na SemVer                             |
|:---------------------------|:-------------------|:---------------------------------------------------------------------------------------------------|:--------------------------------------------|
| **`add`**                  | *Add*              | Jawne dodanie nowych zasobów, modułów lub plików do projektu (często stosowane zamiennie z`feat`). | Brak zmiany (chyba że zmodyfikujesz reguły) |
| **`revert`**               | *Revert*           | Cofnięcie zmian wprowadzonych przez wcześniejszy commit.                                           | Brak (lub zależny od cofanego typu)         |
| **`deps`**                 | *Dependencies*     | Dodanie, usunięcie lub aktualizacja bibliotek i zależności zewnętrznych.                           | Brak zmiany                                 |
| **`sec`** / **`security`** | *Security*         | Poprawka podatności i łatek bezpieczeństwa.                                                        | **PATCH** (jeśli ustawione jak `fix`)       |
| **`types`**                | *Type Hints*       | Uzupełnienie lub zmiana adnotacji typów w kodzie (np. pod mypy).                                   | Brak zmiany                                 |
| **`config`**               | *Configuration*    | Edycja plików konfiguracyjnych aplikacji (np.`logger.toml`, `.env`).                               | Brak zmiany                                 |
| **`wip`**                  | *Work In Progress* | Tymczasowy commit roboczy w trakcie prac (stosowany tylko na gałęziach typu*feature*).             | Brak zmiany                                 |

---

## 3. Zasady działania Semantic Versioning (SemVer)

Format wersji: **`MAJOR.MINOR.PATCH`**

1. **`MAJOR` (Główna wersja):** Podbijana, gdy wprowadzasz zmiany niekompatybilne z poprzednimi wersjami (*Breaking Changes*).
2. **`MINOR` (Mniejsza wersja):** Podbijana, gdy dodajesz nową funkcjonalność (`feat`), która nie psuje istniejącego działania kodu.
3. **`PATCH` (Poprawka):** Podbijana przy naprawie błędów (`fix`), które nie zmieniają sposobu korzystania z systemu.

---

## 4. Ściągawka skrótów JetBrains & macOS

* **`Cmd + K`** – Otwórz okno Commit w PyCharm.
* **`Cmd + Enter`** – Wykonaj commit (gdy fokus znajduje się w oknie Commit).
* **`Cmd + Option + K`** – Wykonaj Commit i przejdź od razu do okna Push.
* **`Option + F12`** – Otwórz / Zamknij terminal w PyCharm.
* **`Cmd + Shift + O`** – Szybkie otwieranie dowolnego pliku (w tym ukrytych, np. `.git/hooks/post-commit`).
* **`Cmd + Shift + K`** – Wyślij commity na zdalne repozytorium (*Push*) – pamiętaj o zaznaczeniu opcji **Push Tags**.
