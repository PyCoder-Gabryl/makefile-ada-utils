--  ============================================================================
--  PROJECT:          @PROJECT@
--  AUTHOR:           @AUTHOR@
--  EMAIL:            @EMAIL@
--  GITHUB:           @GITHUB@
--  LICENSE:          Apache License 2.0
--  ============================================================================
--  DESCRIPTION:      Główny plik projektu GNAT (GPRbuild) dla @PROJECT@.
--                    Integruje rygorystyczny standard stylu (3 spacje),
--                    zaawansowaną analizę formalną SPARK, konfigurację
--                    wieloplatformową (macOS/Linux/Windows) oraz mechanizm
--                    dynamicznego wykluczania sterowników (Omni-Engine).
--                    Zarządza pełnym cyklem budowania, od kompilacji po
--                    generowanie metryk i testów jednostkowych.
--  ============================================================================
--  PATH:             @PROJECT_LOWER@.gpr
--  CREATED:          @DATE@
--  ============================================================================

with "ada_toml";

project @PROJECT@ is

   --  ============================================================================
   --  ZMIENNE ŚRODOWISKOWE I KONFIGURACJA SYSTEMOWA
   --  ============================================================================

   --  EDUKACJA: Funkcja 'external' pozwala na pobieranie wartości z otoczenia
   --  (zmiennych systemowych lub parametrów linii komend -X). Dzięki temu
   --  plik projektu jest elastyczny i reaguje na system operacyjny hosta.
   --  NAPRAWIONO: Dodano "bsd" do typu, aby zapobiec błędowi 'illegal case label "bsd"' w pakietach Ide i Install.
   type Host_OS_Type is ("macos", "windows", "linux", "bsd", "others");
   Host_OS : Host_OS_Type := external ("ALIRE_HOST_OS", "others");

   --  EDUKACJA: Tryb budowania (Build Mode) pozwala na warunkowe włączanie
   --  optymalizacji lub narzędzi diagnostycznych (asercje, debug).
   type Build_Mode_Type is ("debug", "release", "test");
   Build_Mode : Build_Mode_Type := external ("BUILD_MODE", "debug");

   --  EDUKACJA: Zmienna scenariusza dla SPARK. Używamy jej do ukrycia flag
   --  systemowych macOS przed analizatorem logicznym (gnat2why), który ich
   --  nie wspiera. Uruchomienie: 'alr build -- -XSPARK_MODE=On'.
   type SPARK_Mode_Type is ("Off", "On");
   SPARK_Mode : SPARK_Mode_Type := external ("SPARK_MODE", "Off");

   --  Dynamiczne budowanie listy katalogów źródłowych
   Src_Dirs := ("src", "src/**");

   for Source_Dirs use Src_Dirs;
   for Object_Dir use "obj/" & Build_Mode;
   for Exec_Dir use "bin";
   for Main use ("main.adb");

   --  ============================================================================
   --  PAKIET COMPILER (Rygor techniczny i standard stylu)
   --  ============================================================================

package Compiler is

   --  EDUKACJA: Base_Switches definiują rygor projektu.
   Base_Switches :=
     ("-gnat2022",              --  Włączenie najnowszego standardu języka Ada 2022
      "-gnatec=" & @PROJECT@'Project_Dir & "data/config/@PROJECT_LOWER@.adc",
      "-gnatW8",                --  Obsługa kodowania UTF-8
      "-gnatf",                 --  Pełne komunikaty o błędach (Full error info)
      "-gnatU",                 --  Unikalne komunikaty błędów z tagami jednostek
      "-gnatwa",                --  Włączenie niemal wszystkich ostrzeżeń (Warn All)
      "-gnatwe",                --  Traktowanie wszystkich ostrzeżeń jako błędy krytyczne
      "-gnatVa",                --  Włączenie pełnej walidacji danych (Validity checks)
      "-fstack-check",          --  Dynamiczne sprawdzanie przepełnienia stosu
      "-fstack-usage",          --  Generowanie statycznej analizy zużycia stosu
      "-ffunction-sections",    --  Sekcje dla funkcji (optymalizacja linkera)
      "-fdata-sections",        --  Sekcje dla danych (optymalizacja rozmiaru binarki)
      "-fno-strict-aliasing");  --  Wyłączenie restrykcyjnego aliasingu

   --  EDUKACJA: Style_Switches wymuszają dyscyplinę kodu (standard 3-spacjowy).
   Style_Switches :=
     ("-gnaty3",                --  Wymuszenie dokładnie 3 spacji wcięcia
      "-gnatya",                --  Sprawdzanie poprawnej wielkości liter w atrybutach
      "-gnatyb",                --  Całkowity zakaz spacji na końcach linii
      "-gnatyc",                --  Wymóg spacji po znaczniku komentarza -- (czytelność)
      "-gnatyh",                --  Całkowity zakaz używania tabulacji
      "-gnatyi",                --  Weryfikacja poprawnego układu instrukcji IF
      "-gnatyk",                --  Wymuszenie małych liter w słowach kluczowych
      "-gnatyl",                --  Weryfikacja układu sekcji deklaratywnej
      "-gnatym",                --  Kontrola długości podprogramów
      "-gnatyn",                --  Wielkość liter w nazwach bibliotek standardowych
      "-gnatyp",                --  Spójność wielkości liter w pragmach
      "-gnatyr",                --  Sprawdzanie spójności nazw identyfikatorów
      "-gnatys",                --  Wymuszanie posiadania osobnych plików specyfikacji (.ads)
      "-gnatyt",                --  Sprawdzanie poprawności odstępów między tokenami
      "-gnatyM120");            --  Maksymalna dopuszczalna szerokość linii: 120 znaków

   --  Flagi dla trybów budowania (Build Mode)
   Mode_Switches := ();
   case Build_Mode is
      when "debug" | "test" =>
         Mode_Switches :=
           ("-g",               --  Generowanie symboli dla debuggera (GDB/LLDB)
            "-gnata",           --  Włączenie asercji (pragma Assert) i kontraktów
            "-gnato",           --  Włączenie sprawdzania przepełnień (Overflow checks)
            "-O0");             --  Brak optymalizacji (ułatwia debugowanie)

      when "release" =>
         Mode_Switches :=
           ("-O2",              --  Zrównoważona optymalizacja wydajnościowa względem rozmiaru pliku
            "-gnatn");          --  Włączenie mechanizmu Inliningu
   end case;

   --  Flagi dla fazy analizy formalnej SPARK
   SPARK_Switches := ();
   case SPARK_Mode is
      when "On" =>
         SPARK_Switches := ("-gnatd.F");
      when others =>
         null;
   end case;

   --  Jednorazowe i bezpieczne przypisanie wszystkich flag kompilatora
   for Default_Switches ("Ada") use Base_Switches & Style_Switches & Mode_Switches & SPARK_Switches;

end Compiler;

   --  ============================================================================
   --  PAKIET BUILDER (Orkiestracja i wydajność procesu budowania)
   --  ============================================================================

   package Builder is
      --  Wymuszenie wyłączenia ostrzeżeń o aliasingu we WSZYSTKICH projektach zależnych.
      for Global_Compilation_Switches ("Ada") use ("-fno-strict-aliasing", "-gnatwW");

      --  Mapowanie głównego pliku źródłowego na nazwę pliku wykonywalnego.
      for Executable ("main.adb") use "@PROJECT_LOWER@";

      for Switches ("Ada") use (
         "-j0",    --  Wykorzystanie wszystkich rdzeni procesora (kluczowe na Apple Silicon)
         "-k",     --  Keep-going: kontynuuj kompilację mimo błędów w innych jednostkach
         "-s",     --  Smart Compilation: przetwarzaj tylko te pliki, które się zmieniły
         "-m",     --  Minimalna rekompilacja (sprawdzanie sum kontrolnych plików)
         "-gnatQ"  --  Generuj pliki .ali nawet przy błędach (niezbędne dla IDE)
      );

      --  Ustalenie rozszerzenia pliku wykonywalnego w zależności od platformy.
      case Host_OS is
         when "windows" => for Executable_Suffix use ".exe";
         when others    => for Executable_Suffix use "";
      end case;
   end Builder;

   --  ============================================================================
   --  PAKIET BINDER (Zarządzanie inicjalizacją i obsługą błędów)
   --  ============================================================================

   package Binder is
      --  EDUKACJA: Flaga -Es (Symbolic traceback) sprawia, że w razie błędu
      --  program wypisze czytelną ścieżkę (plik i linia), a nie tylko adresy.
      for Switches ("Ada") use ("-E", "-Es");

      case Host_OS is
         when "macos" =>
            --  Dostosowanie rozmiaru stosu dla stabilności zadań na macOS ARM64.
            for Default_Switches ("Ada") use Binder'Default_Switches ("Ada") & ("-D1M");
         when others =>
            null;
      end case;
   end Binder;

--  ============================================================================
   --  PAKIET LINKER (Tworzenie i optymalizacja końcowej binarki)
   --  ============================================================================

   package Linker is
      --  EDUKACJA: Atrybut 'Map_File_Option' generuje szczegółową mapę pamięci.
      for Map_File_Option use "-Wl,-map,@PROJECT_LOWER@.map";

      case Host_OS is
         when "macos" =>
            --  EDUKACJA: Na systemie macOS (Apple Silicon ARM64) pakiet Linker
            --  wymaga atrybutu 'Switches' (zamiast Default_Switches), aby flagi
            --  zostały bezpośrednio przekazane do konsolidatora pliku wykonywalnego.
            for Switches ("Ada") use (
               "-g",                     --  Przekazanie symboli debugowania do linkera (dla LLDB)
               "-Wl,-dead_strip",        --  Usuwanie nieużywanego kodu i martwych sekcji binarki
               "-lm",                    --  Standardowa biblioteka matematyczna języka C (libm)
               "-lpthread"               --  Biblioteka wielowątkowości POSIX Threads
            );

         when "linux" | "windows" =>
            --  Odpowiednik dead_strip dla Linuxa i Windowsa (GNU Linker).
            for Switches ("Ada") use (
               "-Wl,--gc-sections",      --  Usuwanie martwego kodu i nieużywanych sekcji
               "-Wl,--as-needed",        --  Linkuj biblioteki dynamiczne tylko jeśli są rzeczywiście użyte
               "-lm"                     --  Biblioteka matematyczna języka C
            );

         when others =>
            --  Awaryjna konfiguracja konsolidatora dla nierozpoznanych środowisk
            for Switches ("Ada") use (
               "-L/usr/local/lib",       --  Standardowa ścieżka bibliotek UNIX/x86_64
               "-lm"                     --  Biblioteka matematyczna
            );
      end case;
   end Linker;

   --  ============================================================================
   --  PAKIET PRETTY PRINTER (Formatowanie kodu gnatpp)
   --  ============================================================================

   package Pretty_Printer is
      --  EDUKACJA: Pakiet konfigurujący narzędzie 'gnatpp', które dba o
      --  jednolity styl kodu (wcięcia, spacje) w całym zespole.
      for Switches ("Ada") use (
         "-i3",               --  Indentation: Wymuszenie 3 spacji wcięcia (zgodność z -gnaty3)
         "-W8",               --  Obsługa kodowania UTF-8 (zapobiega błędowi s-wchcnv przy polskich znakach)
         "-M120",             --  Maximum line length: Limit 120 znaków na linię
         "-cl3",              --  Comment level: Wcięcia komentarzy również na 3 spacje
         "-nD",               --  No Dozen: Zachowanie formatowania komentarzy dokumentacyjnych
         "-c3",               --  Alignment: Wyrównuj dwukropki w deklaracjach (agresywny poziom 3)
         "-c4",               --  Alignment: Wyrównuj strzałki '=>' w asocjacjach
         "-A1",               --  Align assignments: Wyrównuj znaki przypisania ':='
         "-kL",               --  Keywords Lowercase: Słowa kluczowe zawsze małymi literami
         "-aL",               --  Attributes Lowercase: Pierwsza litera atrybutów wielka
         "-pL",               --  Pragmas Lowercase: Nazwy pragm pierwsza litera wielka
         "-rnb",              --  Remove new lines: Usuwanie zbędnych pustych linii
         "-ff"                --  Form feed: Używaj znaku nowej strony przed podprogramami
      );
   end Pretty_Printer;

   --  ============================================================================
   --  PAKIET PROVE (Konfiguracja formalnej weryfikacji SPARK)
   --  ============================================================================

   package Prove is
      --  EDUKACJA: Konfiguracja silnika dowodzącego SPARK (gnatprove).
      --  --report=all: Pokazuje każdy udowodniony warunek (pełna transparentność).
      --  --prover=z3,cvc5: Wykorzystanie dwóch potężnych silników matematycznych.
      Prove_Switches := (
         "--report=all",         --  Raportuj sukces każdego dowiedzionego warunku
         "--prover=z3,cvc5",     --  Użycie silników SMT Z3 i CVC5
         "--counterexamples=on", --  W razie porażki dowodu pokaż wartości zmiennych
         "--checks-as-errors=on" --  Traktuj naruszenia SPARK jako błędy kompilacji
      );

      case Build_Mode is
         when "debug" | "test" =>
            for Proof_Switches ("Ada") use Prove_Switches &
              ("--level=1",       --  Podstawowa analiza przepływu danych (Data flow)
               "--timeout=5");    --  Szybkie sprawdzenie (max 5 sek. na dowód)

         when "release" =>
            for Proof_Switches ("Ada") use Prove_Switches &
              ("--level=2",       --  Dowodzenie braku błędów Runtime (AoRTE)
               "--steps=1000");   --  Duża liczba kroków dowodzenia
      end case;
   end Prove;

   --  ============================================================================
   --  PAKIET METRICS (Konfiguracja metryk kodu gnatmetric)
   --  ============================================================================

   package Metrics is
      --  EDUKACJA: Pakiet 'Metrics' konfiguruje domyślne przełączniki gnatmetric.
      for Default_Switches ("Ada") use (
         "-v",                      --  Verbose: Pokaż szczegóły procesu analizy
         "-x",                      --  Eksportuj metryki również do formatu XML
         "-o", "@PROJECT_LOWER@_metrics.txt",--  Zapisz główny raport tekstowy do pliku
         "--complexity-all",        --  Złożoność cyklomatyczna (McCabe)
         "--lines-all",             --  Pełne statystyki linii (kod, komentarze)
         "--contract",              --  Zliczanie podprogramów z kontraktami SPARK
         "--post",                  --  Zliczanie podprogramów z warunkami Post
         "--contract-complexity",   --  Obliczanie złożoności samych kontraktów
         "--lines-spark"            --  Zliczanie linii kodu zgodnych ze SPARK
      );
   end Metrics;

   --  ============================================================================
   --  PAKIET GNATTEST (Zarządzanie testami jednostkowymi AUnit)
   --  ============================================================================

   package Gnattest is
      for Tests_Dir use "tests";              --  Katalog docelowy na wygenerowane testy
      for Harness_Dir use "tests/harness";    --  Katalog na infrastrukturę testów
      for Switches use ("--keep-test-dirs", "--skeleton-default=fail");
   end Gnattest;

   --  ============================================================================
   --  NARZĘDZIA POMOCNICZE (Clean i Gnatls)
   --  ============================================================================

   package Clean is
      for Switches use ("-p", "-f");    --  Wymuszone i rekurencyjne czyszczenie
   end Clean;

   package Gnatls is
      for Switches use ("-d");                --  Wyświetlanie pełnej listy zależności
   end Gnatls;

   --  ============================================================================
   --  PAKIET IDE (Integracja z GNAT Studio, VS Code/Codium, JetBrains i Zed)
   --  ============================================================================

   package Ide is

      --  EDUKACJA: Wskazanie systemu kontroli wersji. Integracja z Git pozwala
      --  środowiskom (np. GNAT Studio, CLion) na pokazywanie annotacji gita (blame),
      --  statusu zmian w plikach oraz zarządzanie branchami bezpośrednio z IDE.
      for VCS_Kind use "git";

      --  EDUKACJA: Wskazanie głównego katalogu z dokumentacją projektu.
      --  Edytory i serwery języka (ALS) używają tej ścieżki do indeksowania
      --  podręczników, specyfikacji architektonicznych oraz generowanych raportów.
      for Documentation_Dir use "doc";

      --  =========================================================================
      --  WYBÓR DEBUGGERA W ZALEŻNOŚCI OD PLATFORMY (macOS / Linux / BSD / Windows)
      --  =========================================================================

      --  EDUKACJA: Narzędzia programistyczne (GNAT Studio, VS Code via launch.json)
      --  odczytują atrybut 'Debugger_Command', aby wiedzieć, jaki proces debuggera
      --  uruchomić podczas sesji debugowania.
      case Host_OS is
         when "macos" =>
            --  Na macOS natywnym i wspieranym debuggerem dla architektury ARM64/x86_64 jest LLDB.
            for Debugger_Command use "lldb";

         when "linux" | "bsd" | "windows" =>
            --  Na Linuksie, systemach BSD oraz Windowsie (środowisko MinGW/Alire)
            --  standardem dla języka Ada jest GDB (GNU Debugger).
            for Debugger_Command use "gdb";

         when others =>
            for Debugger_Command use "gdb";
      end case;

      --  =========================================================================
      --  DEDYKOWANE USTAWIENIA DLA GNAT STUDIO I INTEGRACJI Z ALS
      --  =========================================================================

      --  EDUKACJA: Domyślny główny plik wykonywalny do uruchamiania z poziomu IDE.
      for Default_Switches ("gnatls") use ("-d");

   end Ide;

   --  Konfiguracja dla Ada Language Server (używanego przez JetBrains i VS Code).
   package Language_Server is
      for Runtime_Source_Dir ("Ada") use "src";
   end Language_Server;

   --  ============================================================================
   --  PAKIET INSTALL (Wieloplatformowa dystrybucja: macOS / Linux / BSD / Windows)
   --  ============================================================================

   package Install is

      --  =========================================================================
      --  1. ARTEFAKTY I ZASOBY WSPÓŁDZIELONE (CROSS-PLATFORM)
      --  =========================================================================

      --  EDUKACJA: Atrybut 'Artifacts' definiuje pliki i katalogi zasobów statycznych
      --  (niebędące kodem źródłowym Ady), które mają zostać skopiowane do struktury
      --  instalacyjnej (domyślnie prefix/share/<Install_Name>/).
      --  UWAGA: Zgodnie z architekturą projektu używamy "configs" zamiast auto-generowanego "config".
      for Artifacts (".") use ("share", "data", "assets");

      --  EDUKACJA: Identyfikator instalacji – tworzy podkatalog w share/ oraz unikalny
      --  wpis w rejestrze gprinstall na wszystkich systemach operacyjnych.
      for Install_Name use "@PROJECT_LOWER@";

      --  EDUKACJA: Ścieżka podkatalogu dla dokumentacji i plików tekstowych.
      --  Na systemach POSIX: prefix/share/doc/@PROJECT_LOWER@/
      --  Na Windowsie:       <Install_Dir>\doc\
      for Doc_Subdir use "doc";

      --  =========================================================================
      --  2. WARUNKOWE ŚCIEŻKI I TRYBY INSTALACJI (ZALEŻNE OD OS)
      --  =========================================================================

      --  EDUKACJA: W zależności od docelowego systemu operacyjnego (Host_OS)
      --  dostosowujemy docelową strukturę katalogów oraz wywoływane skrypty.
      case Host_OS is
         when "macos" | "linux" | "bsd" =>
            --  Standard FHS (Filesystem Hierarchy Standard) dla systemów UNIX/POSIX.
            for Exec_Subdir use "bin";
            for Mode        use "usage";

            --  Skrypty instalacyjne dla środowisk POSIX (sh/bash)
            --  for Pre_Install_Script  use "scripts/posix_pre_install.sh";
            --  for Post_Install_Script use "scripts/posix_post_install.sh";

         when "windows" =>
            --  Na Windowsie pliki wykonywalne i biblioteki DLL często lądują
            --  w głównym katalogu aplikacji lub w podkatalogu bin.
            for Exec_Subdir use "bin";
            for Mode        use "usage";

            --  Skrypty instalacyjne dla środowiska Windows (PowerShell / Batch)
            --  for Pre_Install_Script  use "scripts/win_pre_install.bat";
            --  for Post_Install_Script use "scripts/win_post_install.bat";

         when others =>
            for Exec_Subdir use "bin";
            for Mode        use "usage";
      end case;

      --  =========================================================================
      --  3. MANIFEST I CONTROL KROKÓW INSTALACJI
      --  =========================================================================

      --  EDUKACJA: Generowanie manifestu instalacji w formacie XML. Pozwala na
      --  precyzyjne odinstalowanie projektu ('gprinstall --uninstall') niezależnie
      --  od platformy, usuwając tylko skopiowane pliki bez naruszania systemu.
      for Manifest use "@PROJECT_LOWER@_install_manifest.xml";

      --  EDUKACJA: Włączenie aktywnej instalacji dla projektu głównego.
      for Active use "True";

      --  EDUKACJA: Zapobiega dublowaniu instalacji wewnętrznych narzędzi deweloperskich.
      for Side_Builds use "False";

      --  =========================================================================
      --  4. KONFIGURACJA DLA LIBRARIES / BINDINGS (ŚRODOWISKA BIBLIOTECZNE)
      --  =========================================================================
      --  Poniższe atrybuty są przydatne, gdyby Bielik w przyszłości eksportował
      --  moduły jako bibliotekę (.a / .dylib / .so / .dll) dla innych aplikacji:
      --
      --  case Host_OS is
      --     when "windows" =>
      --        for Lib_Subdir use "bin";     -- Pliki .dll na Windowsie muszą być w PATH (obok .exe)
      --     when others =>
      --        for Lib_Subdir use "lib";     -- Pliki .so / .dylib w standardowym folderze lib
      --  end case;
      --
      --  for Sources_Subdir use "include/@PROJECT_LOWER@";
      --  for Ali_Subdir     use "lib/@PROJECT_LOWER@/ali";
      --  for Project_Subdir use "share/gpr";

   end Install;

end @PROJECT@;
