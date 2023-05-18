#!/bin/awk


#########----INITIALIZATION---########
BEGIN {

    print "\n---CHORD FINGERINGS FOR STRINGED INSTRUMENTS---\n"

    while (getline < "tones" != 0)
       halftones[$1] = $2
    
    while(getline < "tunings" != 0){
        instruments[$1] = $2
        instrNames[$1] = $3
    }
    loadStrings(instruments["g"])

    fillChar = "-"
    fretLength = 6
    neckLength = 12 * fretLength
    fretNums = getFretNums()
    selMode = 0

    print (promptMsg = "Enter a chord. (x) Change instrument, (q) Quit")
}



########--PROGRAM CONTROL--#########
selMode {
    if($0 in instruments){
        selMode = 0
        loadStrings(instruments[$0])
        print "Current instrument:  " instrNames[$0] " (" instruments[$0] ")"
        print promptMsg
    }
    else print "Unknown instrument"; next
}

/[qQ]/ { exit }
/[xX]/ { instrSel(); selMode = 1; next }


########--PROCESS INPUT--########
{

    tonic = getTonic();
    $0 = substr($0, length(tonic) + 1);

    chordStr = fret("1") minorNinth() secondOrNinth()
    chordStr = chordStr minorThird() majorThird() fourth()
    chordStr = chordStr dimFifth() perfFifth() augFifth() 
    chordStr = chordStr sixth() minorSeventh() majorSeventh()

    print fretNums;

    for(s = length(stringsArray) - 1; s >= 0; s--){
        
        string = stringsArray[s]
        offset = ((halftones[tonic] + 12 - halftones[tolower(string)]) % 12) * fretLength;
        print padStr(string " |>", "-", fretLength, "r") substr(chordStr, neckLength - offset + 1, offset) substr(chordStr, 1, neckLength - offset);
    }

    print fretNums;
    print promptMsg
}



#######---EXIT---#######
END { print "Exit" }




###################################################
########---------UTILITY FUNCTIONS---------########
###################################################

function fret(interval){

    return padStr(interval "|", fillChar, fretLength, "l")
}

function getFretNums(){

    for(i = 11; i >= 0; i--)
        fretNums = padStr("" i, "=", fretLength, "l") fretNums  
   return padStr("", "=", fretLength, "l") fretNums;
}

function padStr(str, c, l, d){# add padding to string. Args: string, padding char, desired length, direction (l/r)

    lim = l - length(str)

    for(j = 0; j < lim; j++){
        if(d ~ /l/) str = c str;
        else if(d ~ /r/) str = str c;
    }
    return str;
}

function instrSel(){

    if(availInstrs == "")
        for(var in instruments)
            availInstrs = availInstrs "(" var ") " instrNames[var] "?   "
    print availInstrs
}

function loadStrings(input){

    if(typeof(stringsArray) !~ /(untyped|unassigned)/) delete stringsArray
    
    split(input, inputChars, "")
    c = 0

    for(i in inputChars){

        if(inputChars[i] ~ /[cCdDeEfFgGaAhH]/)
            stringsArray[c++] = toupper(inputChars[i])
        else if(inputChars[i] ~ /[#bB]/)
            stringsArray[c - 1] = stringsArray[c - 1] tolower(inputChars[i])
    }
}


################################################################
########-----------------CHORD FUNCTIONS----------------########
################################################################



function getTonic() {#

    if($0 ~ /^[cCdDeEfFgGaAhH](#5|b5|[^#b]|$)/)      
        return substr($0, 1, 1)
    else if($0 ~ /^[cCdDeEfFgGaAhH](#|b)([^5]|$)/)
       return substr($0, 1, 2)
    else print "Unknown chord"; next
}


function minorNinth(){

    if($0 ~ /b(2|9)/) return fret("b9")
    return fret("")
}

function secondOrNinth(){

    if($0 ~ /sus2/) return fret("2")
    else if($0 ~ /(^|[^#b])9/) return fret("9")
    else if($0 !~ /add/ && $0 ~ /(11|13)/) return fret("9")
    return fret("")
}

function minorThird(){

    if($0 ~ /sus/) return fret("")
    else if($0 ~ /^m([^aAjJ]|$)/) return fret("m3")
    else if($0 ~ /#9/) return fret("#9")
    return fret("")
}

function majorThird(){
    
    if($0 ~ /sus/) return fret("")
    else if($0 !~ /^m([^aAjJ]|$)/) return fret("M3")
    return fret("")
}

function fourth(){

    if($0 ~ /sus4/) return fret("4")
    else if($0 ~ /(^|[^#b])11/) return fret("11")
    return fret("")
}

function dimFifth(){
    
    if($0 ~ /(b5|dim|°)/) return fret("b5")
    else if($0 ~ /#11/) return fret("#11")
    return fret("")
}

function perfFifth(){

    if($0 !~ /(b5|dim|°|#5|aug|\+)/) return fret("5")
    return fret("")
}

function augFifth(){

    if($0 ~ /#5|aug|\+/) return fret("#5")
    else if($0 ~ /b6/) return fret("b6")
    else if($0 ~ /b13/) return fret("b13")
    return fret("")
}

function sixth(){

    if($0 ~ /(^|[^b#])6/) return fret("6")
    else if($0 ~ /(^|[^b#])13/) return fret("13")
    return fret("")
}

function minorSeventh(){

    if($0 !~ /(maj|M|add)/ && $0 ~ /(7|9|11|13)/) return fret("m7")
    return fret("")
}

function majorSeventh(){

    if($0 ~ /(M|maj)/ && $0 !~ /add/) return fret("M7") 
    return fret("")
}

