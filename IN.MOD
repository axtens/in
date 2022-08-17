MODULE In;
    FROM Storage IMPORT ALLOCATE,
                        DEALLOCATE;
    FROM ASCII IMPORT NUL,
                      ESC;
    FROM System
        IMPORT GetArg,
               Terminate;
    FROM Strings
        IMPORT Append,
               Assign,
               Insert,
               Delete,
               Pos,
               Length;
    FROM FileSpec
        IMPORT ParseFileSpec;
    FROM SHELL
        IMPORT Shell;
    FROM Directories
        IMPORT DirEntry,
               DirQuery,
               NORMAL,
               DIRECTORY;
    FROM INSTRING
        IMPORT InStr;
    FROM XString
        IMPORT UpperCase,
               YesNo;
    FROM XDOS
        IMPORT GetCurDrive;
    FROM InOut
        IMPORT WriteCard,
               WriteLn,
               WriteString,
               WriteLine;
    FROM Terminal
        IMPORT KeyPressed,
               Read;
    CONST
        DRIVE_SEPARATOR = ':';
        PATH_SEPARATOR = '\';
        TYPE_SEPARATOR = '.';
        OPTION_MARKER = '/';
    TYPE
        aDir = ARRAY [0..500] OF DirEntry;
        paDir= POINTER TO aDir;
        PathStr_T = ARRAY [0..126] OF CHAR;
        FileSpec_T = ARRAY [ 0..63 ] OF CHAR;
    VAR
        sFinal   : PathStr_T;
        sFiles   : PathStr_T;
        sCommand : PathStr_T;

        cCount   : CARDINAL;
        cCnt     : CARDINAL;

        zAttr    : BITSET;

        bDebug   : BOOLEAN;

        aDirect  : paDir;

    PROCEDURE BuildArray(
                        rFil : DirEntry
                        );
        BEGIN
            aDirect^[cCount] := rFil;
            INC( cCount)
        END BuildArray;

    PROCEDURE FindRepl(
                      VAR sTarget : ARRAY OF CHAR;
                      sFind       : ARRAY OF CHAR;
                      sRepl       : ARRAY OF CHAR
                      );
        VAR
            cPos : CARDINAL;
            sTempTarget : ARRAY [0..254] OF CHAR;

        BEGIN
            Assign( sTarget,sTempTarget);
            UpperCase( sTempTarget);
            cPos := 0;
            cPos := InStr( cPos, sTempTarget, sFind);
            WHILE cPos <= HIGH( sTempTarget) DO
                Delete( sTarget, cPos, Length( sFind));
                Insert( sRepl, sTarget, cPos);
                Assign( sTarget,sTempTarget);
                UpperCase( sTempTarget);
                cPos := InStr( cPos, sTempTarget, sFind)
            END;
        END FindRepl;

    PROCEDURE Swapper(
                     sCommand       : ARRAY OF CHAR;
                     xDrive         : CHAR;
                     sPath          : ARRAY OF CHAR;
                     sName          : ARRAY OF CHAR;
                     sExt           : ARRAY OF CHAR;
                     VAR sFinalCmd  : ARRAY OF CHAR
                     );
        VAR
            cPos      : CARDINAL;
            sFullSpec : FileSpec_T;
            sNameSpec : FileSpec_T;
            sExtSpec  : FileSpec_T;
            sPathSpec : FileSpec_T;
            sDrivSpec : FileSpec_T;

        BEGIN

            IF xDrive = NUL THEN
                GetCurDrive( 0,xDrive)
            END;

            Assign( xDrive,sDrivSpec);
            Append( sDrivSpec,DRIVE_SEPARATOR);

            sExtSpec := TYPE_SEPARATOR;
            Append( sExtSpec,sExt);

            Assign( sName,sNameSpec);

            Assign( sPath,sPathSpec);

            Assign( sDrivSpec,sFullSpec);
            Append( sFullSpec,sPathSpec);
            IF ( Length( sPathSpec) > 0) THEN
                IF sPathSpec[Length( sPathSpec)-1] # PATH_SEPARATOR THEN
                    Append( sFullSpec,PATH_SEPARATOR);
                END
            END;
            Append( sFullSpec,sNameSpec);
            Append( sFullSpec,sExtSpec);


            FindRepl( sCommand, "$D", sDrivSpec);
            FindRepl( sCommand, "$F", sFullSpec);
            FindRepl( sCommand, "$P", sPathSpec);
            FindRepl( sCommand, "$N", sNameSpec);
            FindRepl( sCommand, "$E", sExtSpec);
            Assign( sCommand,sFinalCmd);
        END Swapper;


PROCEDURE SwapIn( sFile : DirEntry);
    VAR
        xDrive : CHAR;
        sPath  : FileSpec_T;
        sName  : ARRAY [0..7] OF CHAR;
        sExt   : ARRAY [0..2] OF CHAR;
        cRet   : CARDINAL;
        xChar  : CHAR;
        cPos   : CARDINAL;


    BEGIN
        IF KeyPressed() THEN
            Read( xChar);
            IF xChar = ESC THEN
                IF YesNo( "Cancel?") THEN
                    Terminate( 0)
                END
            END
        END;
        ParseFileSpec( sFile.name, xDrive,sPath,sName,sExt);

        cPos := Length( sPath);
        IF cPos > 0 THEN
            DEC( cPos)
        END;

        IF sPath[cPos] # TYPE_SEPARATOR THEN
            Swapper( sCommand, xDrive, sPath, sName, sExt, sFinal);
            IF bDebug THEN
                WriteLine( sFinal)
            END;
            IF NOT Shell( sFinal, cRet) THEN
                WriteString( "Shell Error=");
                WriteCard( cRet,1);
                WriteLn;
                Terminate( 0)
            END;
        END;

        (* Find all occurences of $F $N $E $P $D
                and replace with xDrive+sPath+sName+sExt,sName,sExt,sPath,xDrive *)

END SwapIn;

PROCEDURE Help;
BEGIN
    WriteLine( "");
    WriteLine( 'IN "<command definition>" <filespec> ...');
    WriteLine( "");
    WriteLine( "Symbols used in command definition:");
    WriteLine( " $F = full file specification");
    WriteLine( " $N = file name without extension");
    WriteLine( " $E = file extension");
    WriteLine( " $P = file path without filename or file extension");
    WriteLine( " $D = drive for file");
    WriteLine( "");
    WriteLine( "Example:");
    WriteLine( '  IN "del $F" *.bak');
    WriteLine( "");

END Help;

BEGIN
        WriteLine( "IN v1.5 (c) Copyright Bruce M. Axtens, 1994.");
        GetArg( sCommand,cCnt);
        IF cCnt=0 THEN
            Help;
            Terminate( 0)
        END;
        IF sCommand[0]=OPTION_MARKER THEN
            IF CAP( sCommand[1]) = 'D' THEN
                bDebug := TRUE;
                GetArg( sCommand,cCnt);
                IF cCnt=0 THEN
                    Terminate( 0)
                END;
            END
        END;
        LOOP
            GetArg( sFiles,cCnt);
            IF cCnt=0 THEN
                EXIT
            END;
            zAttr := NORMAL + DIRECTORY;
            NEW( aDirect);
            cCount := 0;
            DirQuery( sFiles,zAttr,BuildArray);
            IF cCount > 0 THEN
                FOR cCnt := 0 TO cCount-1 DO
                    SwapIn( aDirect^[cCnt])
                END;
            END;
            DISPOSE( aDirect);
        END;

END  In.

