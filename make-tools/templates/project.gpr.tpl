--  ============================================================================
--  PROJECT:          @PROJECT@
--  AUTHOR:           @AUTHOR@
--  EMAIL:            @EMAIL@
--  GITHUB:           @GITHUB@
--  LICENSE:          Apache License 2.0
--  ============================================================================
--  DESCRIPTION:      Główny plik projektu GNAT (GPRbuild) dla @PROJECT@.
--                    Integruje rygorystyczny standard stylu (3 spacje),
--                    analizę formalną SPARK, konfigurację wieloplatformową
--                    oraz zarządzanie cyklem budowania i metrykami.
--  ============================================================================
--  PATH:             @PROJECT_LOWER@.gpr
--  CREATED:          @DATE@
--  ============================================================================


with "ada_toml";

project @PROJECT@ is

   type Host_OS_Type is ("macos", "windows", "linux", "bsd", "others");
   Host_OS : Host_OS_Type := external ("ALIRE_HOST_OS", "others");

   type Build_Mode_Type is ("debug", "release", "test");
   Build_Mode : Build_Mode_Type := external ("BUILD_MODE", "debug");

   type SPARK_Mode_Type is ("Off", "On");
   SPARK_Mode : SPARK_Mode_Type := external ("SPARK_MODE", "Off");

   --  Automatyczne wykrywanie wszystkich podkatalogów w src/
   Src_Dirs := ("src", "src/**");

   for Source_Dirs use Src_Dirs;
   for Object_Dir use "obj/" & Build_Mode;
   for Exec_Dir use "bin";
   for Main use ("main.adb");

   --  =========================================================================
   --  PAKIET COMPILER (Rygor techniczny i standard stylu Ada 2022)
   --  =========================================================================

   package Compiler is
      Base_Switches :=
        ("-gnat2022",
         "-gnatW8",
         "-gnatf",
         "-gnatU",
         "-gnatwa",
         "-gnatwe",
         "-gnatVa",
         "-fstack-check",
         "-fstack-usage",
         "-ffunction-sections",
         "-fdata-sections",
         "-fno-strict-aliasing");

      Style_Switches :=
        ("-gnaty3",
         "-gnatya",
         "-gnatyb",
         "-gnatyc",
         "-gnatyh",
         "-gnatyi",
         "-gnatyk",
         "-gnatyl",
         "-gnatym",
         "-gnatyn",
         "-gnatyp",
         "-gnatyr",
         "-gnatys",
         "-gnatyt",
         "-gnatyM120");

      Mode_Switches := ();
      case Build_Mode is
         when "debug" | "test" =>
            Mode_Switches :=
              ("-g",
               "-gnata",
               "-gnato",
               "-O0");
         when "release" =>
            Mode_Switches :=
              ("-O2",
               "-gnatn");
      end case;

      SPARK_Switches := ();
      case SPARK_Mode is
         when "On" =>
            SPARK_Switches := ("-gnatd.F");
         when others =>
            null;
      end case;

      for Default_Switches ("Ada") use
        Base_Switches & Style_Switches & Mode_Switches & SPARK_Switches;
   end Compiler;

   --  =========================================================================
   --  PAKIET BUILDER
   --  =========================================================================

   package Builder is
      for Global_Compilation_Switches ("Ada") use ("-fno-strict-aliasing", "-gnatwW");
      for Executable ("main.adb") use "@PROJECT_LOWER@";
      for Switches ("Ada") use ("-j0", "-k", "-s", "-m", "-gnatQ");

      case Host_OS is
         when "windows" => for Executable_Suffix use ".exe";
         when others    => for Executable_Suffix use "";
      end case;
   end Builder;

   --  =========================================================================
   --  PAKIET BINDER
   --  =========================================================================

   package Binder is
      for Switches ("Ada") use ("-E", "-Es");
   end Binder;

   --  =========================================================================
   --  PAKIET LINKER
   --  =========================================================================

   package Linker is
      for Map_File_Option use "-Wl,-map,@PROJECT_LOWER@.map";

      case Host_OS is
         when "macos" =>
            for Switches ("Ada") use (
               "-g",
               "-Wl,-dead_strip",
               "-lm",
               "-lpthread"
            );
         when "linux" | "windows" =>
            for Switches ("Ada") use (
               "-Wl,--gc-sections",
               "-Wl,--as-needed",
               "-lm"
            );
         when others =>
            for Switches ("Ada") use (
               "-L/usr/local/lib",
               "-lm"
            );
      end case;
   end Linker;

   --  =========================================================================
   --  PAKIET PRETTY PRINTER (Formatowanie gnatpp)
   --  =========================================================================

   package Pretty_Printer is
      for Switches ("Ada") use (
         "-i3",
         "-W8",
         "-M120",
         "-cl3",
         "-nD",
         "-c3",
         "-c4",
         "-A1",
         "-kL",
         "-aL",
         "-pL",
         "-rnb",
         "-ff"
      );
   end Pretty_Printer;

   --  =========================================================================
   --  PAKIET PROVE (Analiza formalna SPARK)
   --  =========================================================================

   package Prove is
      Prove_Switches := (
         "--report=all",
         "--prover=z3,cvc5",
         "--counterexamples=on",
         "--checks-as-errors=on"
      );

      case Build_Mode is
         when "debug" | "test" =>
            for Proof_Switches ("Ada") use Prove_Switches &
              ("--level=1",
               "--timeout=5");
         when "release" =>
            for Proof_Switches ("Ada") use Prove_Switches &
              ("--level=2",
               "--steps=1000");
      end case;
   end Prove;

   --  =========================================================================
   --  PAKIET METRICS
   --  =========================================================================

   package Metrics is
      for Default_Switches ("Ada") use (
         "-v",
         "-x",
         "-o", "@PROJECT_LOWER@_metrics.txt",
         "--complexity-all",
         "--lines-all",
         "--contract",
         "--post",
         "--contract-complexity",
         "--lines-spark"
      );
   end Metrics;

   package Clean is
      for Switches use ("-p", "-f");
   end Clean;

   package Ide is
      for VCS_Kind use "git";
      for Documentation_Dir use "doc";

      case Host_OS is
         when "macos" =>
            for Debugger_Command use "lldb";
         when others =>
            for Debugger_Command use "gdb";
      end case;
   end Ide;

end @PROJECT@;
