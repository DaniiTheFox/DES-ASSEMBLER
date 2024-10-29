// --------------------------------------------------------------------------------------------------------------------------------
// ::::::::: ::::::::  :::::::::  :::    :::          :::      ::::::::  ::::    ::::           :::::::::  :::::::::: ::::::::  
//      :+: :+:    :+: :+:    :+: :+:    :+:        :+: :+:   :+:    :+: +:+:+: :+:+:+          :+:    :+: :+:       :+:    :+: 
//     +:+  +:+        +:+    +:+ +:+    +:+       +:+   +:+  +:+        +:+ +:+:+ +:+          +:+    +:+ +:+       +:+        
//    +#+   +#+        +#++:++#+  +#+    +:+      +#++:++#++: +#++:++#++ +#+  +:+  +#+          +#+    +:+ +#++:++#  +#++:++#++ 
//   +#+    +#+        +#+        +#+    +#+      +#+     +#+        +#+ +#+       +#+          +#+    +#+ +#+              +#+ 
//  #+#     #+#    #+# #+#        #+#    #+#      #+#     #+# #+#    #+# #+#       #+# #+#      #+#    #+# #+#       #+#    #+# 
// ######### ########  ###         ########       ###     ###  ########  ###       ### ###      #########  ########## ########  
// --------------------------------------------------------------------------------------------------------------------------------
JMP _MAIN;
  // ****************************************
  // * BONII'S DES IMPLEMENTATION zCPU ASM  *
  // ****************************************
  // * This is a DES implementation for zcpu*
  // * assembler, please notice that it is  *
  // * still in development and it may have *
  // * multiple bugs inside                 * 
  // ****************************************
// THESE ARE THE BASIC STRINGS FOR PRINTING:
// ARRAY DEFINITION GOES HERE
// ****************************************************************************************
_PCI:                                                                                   // 
    DB 1,5,2,6,3,10,14,15, 8,4,3,2,1,16,15,14, 12,13,11,2,12,10,1,4, 2,3,6,7,3,2,8,9;   // THIS PARTS OF THE CODE
_PC2:                                                                                   // ARE THE SETUP FOR THE ARRAYS
    DB 8,4,6,3,12,16,12,3, 1,4,3,2,7,4,5,6, 10,16,14,12,6,3,1,9, 6,4,16,12,14,12,8,4;   // FOR MY MANAGEMENT FOR PERMUTATION
_MESG:                                                                                  // AND ENCRYPTION MESSAGE 
    DB 'Hello.DesEncrypt',0;                                                            // 
_MESG_SUC;
    DB 'Encryption Success!',0;                                                         // JUST A DEBUG MESSAGE
// ******************************************************************************************
_HALF_DEV1:
    DB 0;

_HALF_DEV2:
    DB 0;

_PERM_KEY1:
    DB 0;

// THESE ARE THE BASIC STRINGS FOR PRINTING: 
_WELCOME:
    DB 'WELCOME TO DES ENCRYPTION!!',0;
_GENKEY1:
    DB 'THE KEY1 GENERATED IS', 0;

// SUBROUTINES GO IN THIS PART
_ASM_GEN_KEYS:
    MOV ECX, 0;                // CLEAN THE FIRST COUNTER REGISTER
    MOV EBX, 0;                // CLEAN THE SECOND COUNTER REGISTER
    MOV R0, _PCI;              // LOAD OUR PERMUTATION ARRAYS
    MOV R1, _PC2;              // INTO EXTENDED MEMORY REGISTERS
    MOV R4, _GENKEY1;          // CALL OUR ARRAY FOR PERMUTATION
    // ----------------- FIRST PERMUTATION WILL GET THE KEY INTO R4 ------------------------------
    PERM1_LOOP:
        CMP ECX, 16;           // THIS IS THE EQUIVALENT TO THE FOR LOOP
        JE  END_P1;            // IF OUT COUNTER IS 16, END ROUTINE
        CMP #ESI, 0;           // TO PREVENT BAD POINTERS
        JE END_P1;             // KILL IF NULL CHAR HAS BEEN CALLED
        MOV R3, 0;             // THIS WILL WORK AS A REFERENCE TO REVERT INCREMENT
        // -------------------------------------------------------------------------
        PERM:
            CMP R2, #R0;       // IF OUR POINTER IS THE SAME AS THE INDEX OF THE NUMBER
            JE NXT;            // STOP THE INDEXING SEGMENT
            INC ESI;           // ELSE INCREMENT ESI POINTER TO GET THE CHARACTER FOR PERM
            ADD R3, 1;         // INCREMENT THE REVERSING POINTER
            ADD R2, 1;         // INCREMENT OUR NORMAL POINTER
        JMP PERM;
        NXT:                   // ONCE WE INDEX THE WORD, RETURN 
        INC R0;                // INCREMENT THE CHARACTER FOR THE ARRAY OF PERM
        MOV #R4, #ESI;         // PUSH OUR PERMUTATED CHAR INTO R4 _GENKEY ARRAY
        INC R4;                // MOVE TO NEXT POSITION ON R4
        CLEAR:                 // NOW WE CLEAN OUR POINTERS AND MEMORY TO RESET
            CMP R3, 0;         // TEST IF R3 IS SET TO 0 MOVES AGAIN
            JE STP_CLS;        // JUMP IF EQUALS 0 
            DEC ESI;           // ELSE DECREASE ESI POINTER
            SUB R3, 1;         // SUBTRACT 1 TO OUR MOVE COUNTER
        JMP CLEAR;
        STP_CLS:               // THIS BASICALLY RESETS THE POSITION TO KEEP TRACK OF OUR CHARS 
        MOV R2, 0;             // NOW WE CLEAN THE MEMORY
        // -----------------------------------------------------------------------
        ADD ECX, 1;
    JMP PERM1_LOOP;
    END_P1:
    // ---------------------------------------------------------------------------------------------------
    MOV R2, 0;                  // THIS IS THE PART WHERE I SPLIT THE SEGMENTS IN 2
    MOV R3, 0;                  // IN THE EXTENDED MEMORY R5,R6
    MOV R5, _HALF_DEV1;         // I STORE THE DBYTES 
    MOV R6, _HALF_DEV2;         // SO I CAN ACCESS THEM USING POINTERS
    MOV R2, R4;                 //
    SPLIT_STR:                  // FOR EACH CHARACTER I'LL TEST IT'S POSITINO
        CMP R3, 16;             // TO DEFINE WHERE TO STORE IT
        JE ST_DIE;                       
        CMP R2, 8;              
        JLE _LEFT_SPL;          // JUMP TO SPLIT LEFT IF LOWER
        JMP _RIGHT_SPL;         // JUMP TO SPLIT RIGHT IF HIGHER
        _LEFT_SPL:
            MOV #R5, #R2;       // MOVE VALUE IN POINTER
            INC R5;             // INCREMENT BOTH POINTERS
            INC R2;
            JMP FINI;
        _RIGHT_SPL:
            MOV #R6, #R2;       // MOVE VALUES IN POINTERS
            INC R6;             // INCREMENT BOTH POINTERS
            INC R2;
        FINI:
        ADD R3,1;
    JMP SPLIT_STR;              // REPEAT THE LOOP
    ST_DIE:
    // ---------------------------------------------------------------------------------------------------
    // BY THIS POINT THE STRINGS FROM THE PERMUTATION SHOULD BE SPLIT INTO LEFT AND RIGHT
    // ---------------------------------------------------------------------------------------------------
    // To this moment memory should look like:
    //      R2 - LEFT                 * 
    //      R3 - RIGHT                * WE CAN NOW CLEAN MEMORY
    //      R0 - PERM ARRAY 1         * THAT IS NOT BEING USED
    //      R1 - PERM ARRAY 2         * TO HAVE MORE SPACE 
    //      ESI- ORIGINAL STRING      * TO WORK
    //      EDX- BACKGROUND COLOR     * 
    // ----------------------------------------------------------------------------------------------------
    // NEW MEMORY CLEANUP
    MOV EBP, R5;         // WE SAVE THE CURRENT VALUES TO PREVENT A LOSS
    MOV R7, R6;          // WHILE CLEANING OUR MEMORY 
    // ------------------
    MOV R5, 0;           // THIS SEGMENT IS THE CLEANUP
    MOV R4, 0;           // OF OUR EXTENDED MEMORY
    MOV R3, 0;           // MADE TO ORGANIZE
    MOV R6, 0;           // AND RESET EVERYTHING
    MOV R2, 0;           // FOR NEW USAGE
    // ------------------
    MOV R2, ESI;         // 
    MOV ESI, 0;          // THIS RESETS THE INCREMENT POINTER FOR ESI
    MOV ESI, R2;         // SO WE CAN PERFORM NEW OPERATIONS EASILY
    MOV R2, 0;           // 
    // ------------------
    MOV R2, R0;          //
    MOV R0, 0;           // THIS RESETS THE INCREMENT POINTER FOR PC1
    MOV R0, R2;          //
    MOV R2, 0;           //
    // ------------------
    MOV R2, R1;          //
    MOV R1, 0;           // THIS RESETS THE INCREMENT POINTER FOR PC2
    MOV R1, R2;          //
    MOV R2, 0;           // 
    // ------------------
    MOV R2, R7;          // MOVE THE KEY LEFT  TO R2
    MOV R3, EBP;         // MOVE THE KEY RIGHT TO R3
    // ------------------
    MOV R7, 0;           // FINAL CLEANUP
    MOV EBP, 0;
    // ----------------------------------------------------------------------------------------------------
    // R4 IS MY NEW LOOP REGISTER 
    // ----------------------------------------------------------------------------------------------------
    _SHIFT_KEYS:                     // NOW WE PERFORM THE SHIFT LOOPS
        CMP R4, 2;                   
            JE _END_SH;              // SO WE PERFORM THIS PROCESS 2 TIMES PER HALF
            _LEFT_SHIFT:             // FOR THE FIRST HALF 
                CMP EBP, 8;          // WE MUSR SHIFT THE BITS OF THE LETTERS 
                    JE _LSH_END;     // TO THE LEFT
                    BSHL #R2, 1;     // AND STORE IT ON R2
                    INC R2;
                ADD EBP, 1;
            JMP _LEFT_SHIFT;
            _LSH_END:
    // ----------------------------------------------------------------------------------------------------
            MOV EBP, 0;               // ALSO CLEAN POINTER
            _RIGHT_SHIFT:             // WE DO THE SAME FOR THIS
                CMP EBP, 8;
                    JE _RSH_END;      // AND NOW WE SHIFT TO THE RIGHT
                    BSHR #R3, 1;      // THESE BITS, SO WE HAVE HASHED VALUE
                    INC R3;           // INCREMENT THE R3 POINTER
                ADD EBP, 1;
            JMP _RIGHT_SHIFT;         // THESE PROCESSES PROTECT THE GENERATED KEYS
            _RSH_END:
    // ----------------------------------------------------------------------------------------------------
        ADD R4, 1;                    // SWAP COUNTER REGISTER
    JMP _SHIFT_KEYS;                  // REPEAT THE LOOP
    _END_SH:                          // END THE LOOP
    // ----------------------------------------------------------------------------------------------------
    // THIS IS A NEW CLEAN OPERATION FOR THE MEMORY TO KEEP IT AS ORGANIZED AS POSSIBLE
    // ----------------------------------------------------------------------------------------------------

RET;
// --------------------------------------------------------------------------------------------------------
// NOT TESTED THIS LINE FOR THE ASSEMBLER!!!!! -- EXPERIMENTAL MODE
ENDLINE:
    MOV EAX, 65536;           // CALL THE WRITING POINTER FOR THE ASSEMBLER DISPLAY
    MOV [EAX+R27], '\n';      // PUSH THE NEW LINE CHARACTER TO THE LINE
    INC R27;                  // CALL THE NEW INDEX
RET;
// ---------------------------------------------------------------------------------------------------------
ASM_PRINT_STR:
    MOV EAX, 65536;            // MOVE THE POINTER FOR ACCESSING THE SYSTEM CALL
        WRT_LOOP:              // A LOOP THROUGH ALL THE CHARACTERS OF THE STRING
            CMP #ESI, 0;       // IF IT'S THE ENDING STRING CHARACTER THEN:
            JE  DIE;           // STOP THE LOOP
            MOV #EAX, #ESI;    // MOVE THE CHARACTER OF THE STRING STORED IN ESI TO EAX
            INC EAX;           // INCREMENT THE EAX POINTER TO NEXT POS
            MOV #EAX, EDX;     // MOVE EDX (FOREGROUND COLOR) TO EAX
            INC EAX;           // INCREMENT EAX POSITION AGAIN
            INC ESI;           // INCREMENT THE ESI POINTER FOR NEXT CHARACTER
    JMP WRT_LOOP;              // REPEAT THE LOOP
    DIE:
RET;                           // RETURN TO THE CALL METHOD
// ------------------------------------------------------------------------------------------------------------
// MAIN ROUTINE IS THIS PART 
_MAIN:
    MOV ESI, _WELCOME;         // ADD MESSAGE PARAMETER
    MOV EDX, 000999;           // ADD FOREGROUND COLOR
    CALL ASM_PRINT_STR;        // CALL THE FUNCTION
    MOV ESI, _MESG;
    CALL ENDLINE;
    MOV EDX, 000999;
    CALL _ASM_GEN_KEYS;
    MOV ESI, _MESG_SUC;
    MOV EDX, 000999;
    CALL ASM_PRINT_STR;
// -------------------------------------------------------------------------------------------------------------
