--  ============================================================================
--  PROJECT:          @PROJECT@ Tests
--  AUTHOR:           @AUTHOR@
--  EMAIL:            @EMAIL@
--  GITHUB:           @GITHUB@
--  LICENSE:          Apache License 2.0
--  ============================================================================
--  DESCRIPTION:      Projekt GNAT dla testów jednostkowych AUnit projektu @PROJECT@.
--                    Kompiluje i uruchamia niezależną uprząż testową test_runner.
--  ============================================================================
--  PATH:             tests/tests.gpr
--  CREATED:          @DATE@
--  ============================================================================

with "aunit";

project Tests is

   for Source_Dirs use ("../src", "../src/**", ".");
   for Object_Dir use "obj";
   for Exec_Dir use "bin";
   for Main use ("test_runner.adb");

   package Compiler is
      for Default_Switches ("Ada") use
        ("-gnat2022",
         "-g",
         "-gnata",
         "-gnatwa",
         "-gnatwe");
   end Compiler;

   package Builder is
      for Executable ("test_runner.adb") use "test_runner";
      for Switches ("Ada") use ("-j0", "-s");
   end Builder;

end Tests;
