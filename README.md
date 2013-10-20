# Amiga-startup

Base code and build process for demos etc.

Can convert images to Amiga bitmaps.

Supports defensive programming using asserts in debug builds.

System shutdown and demo startup were taken from Blueberry's
[BlueBerryDemoStartup](http://ada.untergrund.net/forum/index.php?action=vthread&forum=4&topic=444)

## Assert macros

If DEBUG is defined, the assert* macros check whether a
condition is true, and fails if it is not.
Use this to make sure that an assumption you are making in
your code is really true at runtime.

For example, if you code assumes that the value of d1.w is 1,
you can add a check like this:

    assertw eq,#1,d1,$f00

This checks (using cmp.w) whether d1 is 1.
If d1 is not 1, freezes showing a screen with a red pattern.

A common use for this is to check for buffer overruns:

        lea someData,a0
    someLoop:
        move #someValue,(a0)+  ; etc.
        dbra d0,someLoop  ;or similar
        ; ls is the "lower or same" cc
        assertl ls,#endOfData,a0,$ff0

    someData:
        dcb.l 100
    endOfData:

See debug.s for documentation of all macros.

The assert macros do nothing if DEBUG is not defined,
so you can be liberal with them,
and not have to worry about the performance in a "release" build.
