# Roadmapa - @PROJECT@

Konwencja: kamienie milowe m0..mN. Kazdy kamien konczy sie dzialajacym budowaniem, przechodzacymi testami AUnit i
dowodem SPARK co najmniej poziomu 1.

## m0 - Fundament

- [x] struktura katalogow + Makefile (szablon make-templ)
- [x] repozytorium Git + hook commit-msg
- [ ] repozytorium na GitHubie (`make gh-repo`)
- [ ] uzupelniony manifest `alire.toml` (authors, licenses, tags)

## m1 - Rdzen dziedziny

- [ ] pakiet (y) w `src/core` z kontraktami Pre/Post
- [ ] testy AUnit dla core
- [ ] `make prove-l2` bez czerwonych dowodow

## m2 - ...

- [ ] ...

## Zasady techniczne (obowiazujace w kazdym kamieniu)

- 1 plik = 1 odpowiedzialnosc; nowy modul przez `make new-module`
- `pragma SPARK_Mode (On)` + kontrakty na interfejsach publicznych
- kazdy modul dziedzinowy ma testy w `tests/`
- commity wg `CONTRIBUTING.md`; wersje przez `make bump LEVEL=...`
