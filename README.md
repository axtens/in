# in
Command line tool applying patterned commands to files

Written 1994 in Fitted Software Tools Modula-2. See the [xlb](https://github.com/axtens/xlb) project for required non-FST libraries (e.g. SHELL).
```
IN "<command definition>" <filespec> ...

Symbols used in command definition:
 $F = full file specification
 $N = file name without extension
 $E = file extension
 $P = file path without filename or file extension
 $D = drive for file

Example:
  IN "del $F" *.bak
```
Since made redundant by CMD's FOR extensions.

Building and/or converting to another Modula-2 is left as a task for the reader and/or the author should he find the time.

Other Modula-2 compilers: [M2F](http://floppsie.comp.glam.ac.uk/Glamorgan/gaius/web/m2fabout.html), [GNU Modula-2](https://www.nongnu.org/gm2/download.html), [XDS](https://github.com/excelsior-oss/xds) and 
[ADW](https://www.modula2.org/adwm2/).

Other good Modula-2 information can be found at [Peter Moylan](http://www.pmoylan.org/pages/m2/Modula2.html)'s site.

