# @PROJECT@

> Projekt Ada / SPARK / Alire utworzony z szablonu make-templ (@YEAR@).

## Opis

<!-- Jeden akapit: co robi projekt, dla kogo i po co. -->

## Wymagania

- GNAT + GNATprove (SPARK) - np. wydanie FSF przez Alire
- Alire (`alr`) - zależności i budowanie
- opcjonalnie: GNATcov (pokrycie), GNATtest (szkielety testów), `gh` (GitHub CLI), `zip`

## Szybki start

```bash
make help         # plaska lista polecen
make workflow     # przewodnik po 4 metasekcjach cyklu zycia
make doctor       # diagnostyka narzedzi i sciezek
make build        # kompilacja debug
make run          # uruchomienie przez alr
make test-aunit   # testy jednostkowe AUnit
make prove-l1     # analiza SPARK (poziom 1)
make coverage     # pokrycie kodu (raport XCOV/HTML)
```

## Struktura katalogów

| Katalog       | Rola                                            |
|---------------|-------------------------------------------------|
| `src/config`  | konfiguracja aplikacji (TOML + fallback w kodzie) |
| `src/core`    | logika dziedzinowa bez I/O                      |
| `src/i18n`    | teksty, komunikaty, tłumaczenia                 |
| `src/logging` | rejestrowanie zdarzeń                           |
| `src/app`     | kompozycja i orkiestracja aplikacji             |
| `src/driver`  | sterowniki i integracje zewnętrzne              |
| `src/ui`      | warstwa prezentacji                             |
| `tests`       | uprząż AUnit (`tests/gen`, `tests/harness` = GNATtest) |
| `doc`         | dokumentacja projektowa                         |
| `make-templ`  | szablony plików + kanoniczny Makefile           |

## Konwencje

- commity i wersjonowanie: `CONTRIBUTING.md`
- kamienie milowe: `ROADMAP.md.tpl`
- nowy moduł: `make new-module NAME=nazwa DIR=core`

## Licencja

Apache License 2.0 - patrz plik `LICENSE`.

## Autor

@AUTHOR@ <@EMAIL@>
