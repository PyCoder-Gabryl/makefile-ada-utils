# Konwencje współpracy - @PROJECT@

## Commity

Format: `prefiks: opis po polsku` (tryb rozkazujący, bez kropki na końcu).
Format waliduje hook `.git/hooks/commit-msg` (instaluje `make git-init`).

Dozwolone prefiksy:

| Prefiks    | Kiedy                                         |
|------------|-----------------------------------------------|
| `add`      | nowy moduł / funkcjonalność                   |
| `fix`      | poprawka błędu                                |
| `docs`     | dokumentacja (README, ROADMAP, komentarze)    |
| `test`     | testy AUnit / GNATtest                        |
| `refactor` | zmiana struktury bez zmiany zachowania        |
| `style`    | formatowanie (gnatpp), porządki               |
| `perf`     | optymalizacja                                 |
| `build`    | Makefile, GPR, alire.toml, szablony           |
| `ci`       | automatyzacja / hooki                         |
| `chore`    | rzeczy porządkowe poza kodem                  |
| `revert`   | cofnięcie commita                             |
| `release`  | podbicie wersji i tag                         |
| `bump`     | commit wersji tworzony przez hook post-commit |

Przykłady:

- `add: moduł bielik-core-config (odczyt TOML z fallbackiem)`
- `fix: obsługa braku pliku logger.toml w src/logging`
- `docs: aktualizacja roadmapy m2`

## Wersjonowanie

- `make bump LEVEL=patch|minor|major` - ścieżka bez zależności
  (podbija VERSION + alire.toml + .cz.toml)
- hook `post-commit`: jeśli jest zainstalowany commitizen (`cz`), po każdym
  commicie sam zrobi `cz bump --files-only` i commit `bump: version -> X.Y.Z`
  z sufiksem `+git.<hash>` w VERSION; bez `cz` hook tylko informuje i nie
  przeszkadza
- tagi w postaci `vX.Y.Z`

## Kod

- SPARK: `pragma SPARK_Mode (On)` w modułach dowodzonych; kontrakty Pre/Post
  na interfejsach publicznych
- 1 plik = 1 odpowiedzialność; moduły w `src/<podkatalog>`
- nowy moduł: `make new-module NAME=nazwa DIR=core`
- testy: własna uprząż AUnit w `../../tests`; szkielety może wygenerować
  `make test-gen`
- przed commitem: `make syntax` + `make test-aunit`; przy zmianie kontraktów
  `make prove-l2`

## Autor

@AUTHOR@ <@EMAIL@>
