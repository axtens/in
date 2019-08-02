# in
Command line tool applying patterned commands to files

Written 1994 in Fitted Software Tools Modula-2
```
IN "<command definition>" <filespec> ...'

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
