local correction, control, alternate, figment, abbreviation = 
	"correction", "control", "alternate", "figment", "abbreviation"

return {
	[0x000000] = {
		{      control, "NULL" };
		{ abbreviation, "NUL" };
	};
	[0x000001] = {
		{      control, "START OF HEADING" };
		{ abbreviation, "SOH" };
	};
	[0x000002] = {
		{      control, "START OF TEXT" };
		{ abbreviation, "STX" };
	};
	[0x000003] = {
		{      control, "END OF TEXT" };
		{ abbreviation, "ETX" };
	};
	[0x000004] = {
		{      control, "END OF TRANSMISSION" };
		{ abbreviation, "EOT" };
	};
	[0x000005] = {
		{      control, "ENQUIRY" };
		{ abbreviation, "ENQ" };
	};
	[0x000006] = {
		{      control, "ACKNOWLEDGE" };
		{ abbreviation, "ACK" };
	};
	[0x000007] = {
		{      control, "ALERT" };
		{ abbreviation, "BEL" };
	};
	[0x000008] = {
		{      control, "BACKSPACE" };
		{ abbreviation, "BS" };
	};
	[0x000009] = {
		{      control, "CHARACTER TABULATION" };
		{      control, "HORIZONTAL TABULATION" };
		{ abbreviation, "HT" };
		{ abbreviation, "TAB" };
	};
	[0x00000a] = {
		{      control, "LINE FEED" };
		{      control, "NEW LINE" };
		{      control, "END OF LINE" };
		{ abbreviation, "LF" };
		{ abbreviation, "NL" };
		{ abbreviation, "EOL" };
	};
	[0x00000b] = {
		{      control, "LINE TABULATION" };
		{      control, "VERTICAL TABULATION" };
		{ abbreviation, "VT" };
	};
	[0x00000c] = {
		{      control, "FORM FEED" };
		{ abbreviation, "FF" };
	};
	[0x00000d] = {
		{      control, "CARRIAGE RETURN" };
		{ abbreviation, "CR" };
	};
	[0x00000e] = {
		{      control, "SHIFT OUT" };
		{      control, "LOCKING-SHIFT ONE" };
		{ abbreviation, "SO" };
	};
	[0x00000f] = {
		{      control, "SHIFT IN" };
		{      control, "LOCKING-SHIFT ZERO" };
		{ abbreviation, "SI" };
	};
	[0x000010] = {
		{      control, "DATA LINK ESCAPE" };
		{ abbreviation, "DLE" };
	};
	[0x000011] = {
		{      control, "DEVICE CONTROL ONE" };
		{ abbreviation, "DC1" };
	};
	[0x000012] = {
		{      control, "DEVICE CONTROL TWO" };
		{ abbreviation, "DC2" };
	};
	[0x000013] = {
		{      control, "DEVICE CONTROL THREE" };
		{ abbreviation, "DC3" };
	};
	[0x000014] = {
		{      control, "DEVICE CONTROL FOUR" };
		{ abbreviation, "DC4" };
	};
	[0x000015] = {
		{      control, "NEGATIVE ACKNOWLEDGE" };
		{ abbreviation, "NAK" };
	};
	[0x000016] = {
		{      control, "SYNCHRONOUS IDLE" };
		{ abbreviation, "SYN" };
	};
	[0x000017] = {
		{      control, "END OF TRANSMISSION BLOCK" };
		{ abbreviation, "ETB" };
	};
	[0x000018] = {
		{      control, "CANCEL" };
		{ abbreviation, "CAN" };
	};
	[0x000019] = {
		{      control, "END OF MEDIUM" };
		{ abbreviation, "EOM" };
	};
	[0x00001a] = {
		{      control, "SUBSTITUTE" };
		{ abbreviation, "SUB" };
	};
	[0x00001b] = {
		{      control, "ESCAPE" };
		{ abbreviation, "ESC" };
	};
	[0x00001c] = {
		{      control, "INFORMATION SEPARATOR FOUR" };
		{      control, "FILE SEPARATOR" };
		{ abbreviation, "FS" };
	};
	[0x00001d] = {
		{      control, "INFORMATION SEPARATOR THREE" };
		{      control, "GROUP SEPARATOR" };
		{ abbreviation, "GS" };
	};
	[0x00001e] = {
		{      control, "INFORMATION SEPARATOR TWO" };
		{      control, "RECORD SEPARATOR" };
		{ abbreviation, "RS" };
	};
	[0x00001f] = {
		{      control, "INFORMATION SEPARATOR ONE" };
		{      control, "UNIT SEPARATOR" };
		{ abbreviation, "US" };
	};
	[0x000020] = {
		{ abbreviation, "SP" };
	};
	[0x00007f] = {
		{      control, "DELETE" };
		{ abbreviation, "DEL" };
	};
	[0x000080] = {
		{      figment, "PADDING CHARACTER" };
		{ abbreviation, "PAD" };
	};
	[0x000081] = {
		{      figment, "HIGH OCTET PRESET" };
		{ abbreviation, "HOP" };
	};
	[0x000082] = {
		{      control, "BREAK PERMITTED HERE" };
		{ abbreviation, "BPH" };
	};
	[0x000083] = {
		{      control, "NO BREAK HERE" };
		{ abbreviation, "NBH" };
	};
	[0x000084] = {
		{      control, "INDEX" };
		{ abbreviation, "IND" };
	};
	[0x000085] = {
		{      control, "NEXT LINE" };
		{ abbreviation, "NEL" };
	};
	[0x000086] = {
		{      control, "START OF SELECTED AREA" };
		{ abbreviation, "SSA" };
	};
	[0x000087] = {
		{      control, "END OF SELECTED AREA" };
		{ abbreviation, "ESA" };
	};
	[0x000088] = {
		{      control, "CHARACTER TABULATION SET" };
		{      control, "HORIZONTAL TABULATION SET" };
		{ abbreviation, "HTS" };
	};
	[0x000089] = {
		{      control, "CHARACTER TABULATION WITH JUSTIFICATION" };
		{      control, "HORIZONTAL TABULATION WITH JUSTIFICATION" };
		{ abbreviation, "HTJ" };
	};
	[0x00008a] = {
		{      control, "LINE TABULATION SET" };
		{      control, "VERTICAL TABULATION SET" };
		{ abbreviation, "VTS" };
	};
	[0x00008b] = {
		{      control, "PARTIAL LINE FORWARD" };
		{      control, "PARTIAL LINE DOWN" };
		{ abbreviation, "PLD" };
	};
	[0x00008c] = {
		{      control, "PARTIAL LINE BACKWARD" };
		{      control, "PARTIAL LINE UP" };
		{ abbreviation, "PLU" };
	};
	[0x00008d] = {
		{      control, "REVERSE LINE FEED" };
		{      control, "REVERSE INDEX" };
		{ abbreviation, "RI" };
	};
	[0x00008e] = {
		{      control, "SINGLE SHIFT TWO" };
		{      control, "SINGLE-SHIFT-2" };
		{ abbreviation, "SS2" };
	};
	[0x00008f] = {
		{      control, "SINGLE SHIFT THREE" };
		{      control, "SINGLE-SHIFT-3" };
		{ abbreviation, "SS3" };
	};
	[0x000090] = {
		{      control, "DEVICE CONTROL STRING" };
		{ abbreviation, "DCS" };
	};
	[0x000091] = {
		{      control, "PRIVATE USE ONE" };
		{      control, "PRIVATE USE-1" };
		{ abbreviation, "PU1" };
	};
	[0x000092] = {
		{      control, "PRIVATE USE TWO" };
		{      control, "PRIVATE USE-2" };
		{ abbreviation, "PU2" };
	};
	[0x000093] = {
		{      control, "SET TRANSMIT STATE" };
		{ abbreviation, "STS" };
	};
	[0x000094] = {
		{      control, "CANCEL CHARACTER" };
		{ abbreviation, "CCH" };
	};
	[0x000095] = {
		{      control, "MESSAGE WAITING" };
		{ abbreviation, "MW" };
	};
	[0x000096] = {
		{      control, "START OF GUARDED AREA" };
		{      control, "START OF PROTECTED AREA" };
		{ abbreviation, "SPA" };
	};
	[0x000097] = {
		{      control, "END OF GUARDED AREA" };
		{      control, "END OF PROTECTED AREA" };
		{ abbreviation, "EPA" };
	};
	[0x000098] = {
		{      control, "START OF STRING" };
		{ abbreviation, "SOS" };
	};
	[0x000099] = {
		{      figment, "SINGLE GRAPHIC CHARACTER INTRODUCER" };
		{ abbreviation, "SGC" };
	};
	[0x00009a] = {
		{      control, "SINGLE CHARACTER INTRODUCER" };
		{ abbreviation, "SCI" };
	};
	[0x00009b] = {
		{      control, "CONTROL SEQUENCE INTRODUCER" };
		{ abbreviation, "CSI" };
	};
	[0x00009c] = {
		{      control, "STRING TERMINATOR" };
		{ abbreviation, "ST" };
	};
	[0x00009d] = {
		{      control, "OPERATING SYSTEM COMMAND" };
		{ abbreviation, "OSC" };
	};
	[0x00009e] = {
		{      control, "PRIVACY MESSAGE" };
		{ abbreviation, "PM" };
	};
	[0x00009f] = {
		{      control, "APPLICATION PROGRAM COMMAND" };
		{ abbreviation, "APC" };
	};
	[0x0000a0] = {
		{ abbreviation, "NBSP" };
	};
	[0x0000ad] = {
		{ abbreviation, "SHY" };
	};
	[0x0001a2] = {
		{   correction, "LATIN CAPITAL LETTER GHA" };
	};
	[0x0001a3] = {
		{   correction, "LATIN SMALL LETTER GHA" };
	};
	[0x00034f] = {
		{ abbreviation, "CGJ" };
	};
	[0x00061c] = {
		{ abbreviation, "ALM" };
	};
	[0x000709] = {
		{   correction, "SYRIAC SUBLINEAR COLON SKEWED LEFT" };
	};
	[0x000cde] = {
		{   correction, "KANNADA LETTER LLLA" };
	};
	[0x000e9d] = {
		{   correction, "LAO LETTER FO FON" };
	};
	[0x000e9f] = {
		{   correction, "LAO LETTER FO FAY" };
	};
	[0x000ea3] = {
		{   correction, "LAO LETTER RO" };
	};
	[0x000ea5] = {
		{   correction, "LAO LETTER LO" };
	};
	[0x000fd0] = {
		{   correction, "TIBETAN MARK BKA- SHOG GI MGO RGYAN" };
	};
	[0x0011ec] = {
		{   correction, "HANGUL JONGSEONG YESIEUNG-KIYEOK" };
	};
	[0x0011ed] = {
		{   correction, "HANGUL JONGSEONG YESIEUNG-SSANGKIYEOK" };
	};
	[0x0011ee] = {
		{   correction, "HANGUL JONGSEONG SSANGYESIEUNG" };
	};
	[0x0011ef] = {
		{   correction, "HANGUL JONGSEONG YESIEUNG-KHIEUKH" };
	};
	[0x00180b] = {
		{ abbreviation, "FVS1" };
	};
	[0x00180c] = {
		{ abbreviation, "FVS2" };
	};
	[0x00180d] = {
		{ abbreviation, "FVS3" };
	};
	[0x00180e] = {
		{ abbreviation, "MVS" };
	};
	[0x00200b] = {
		{ abbreviation, "ZWSP" };
	};
	[0x00200c] = {
		{ abbreviation, "ZWNJ" };
	};
	[0x00200d] = {
		{ abbreviation, "ZWJ" };
	};
	[0x00200e] = {
		{ abbreviation, "LRM" };
	};
	[0x00200f] = {
		{ abbreviation, "RLM" };
	};
	[0x00202a] = {
		{ abbreviation, "LRE" };
	};
	[0x00202b] = {
		{ abbreviation, "RLE" };
	};
	[0x00202c] = {
		{ abbreviation, "PDF" };
	};
	[0x00202d] = {
		{ abbreviation, "LRO" };
	};
	[0x00202e] = {
		{ abbreviation, "RLO" };
	};
	[0x00202f] = {
		{ abbreviation, "NNBSP" };
	};
	[0x00205f] = {
		{ abbreviation, "MMSP" };
	};
	[0x002060] = {
		{ abbreviation, "WJ" };
	};
	[0x002066] = {
		{ abbreviation, "LRI" };
	};
	[0x002067] = {
		{ abbreviation, "RLI" };
	};
	[0x002068] = {
		{ abbreviation, "FSI" };
	};
	[0x002069] = {
		{ abbreviation, "PDI" };
	};
	[0x002118] = {
		{   correction, "WEIERSTRASS ELLIPTIC FUNCTION" };
	};
	[0x002448] = {
		{   correction, "MICR ON US SYMBOL" };
	};
	[0x002449] = {
		{   correction, "MICR DASH SYMBOL" };
	};
	[0x002b7a] = {
		{   correction, "LEFTWARDS TRIANGLE-HEADED ARROW WITH DOUBLE VERTICAL STROKE" };
	};
	[0x002b7c] = {
		{   correction, "RIGHTWARDS TRIANGLE-HEADED ARROW WITH DOUBLE VERTICAL STROKE" };
	};
	[0x00a015] = {
		{   correction, "YI SYLLABLE ITERATION MARK" };
	};
	[0x00fe00] = {
		{ abbreviation, "VS1" };
	};
	[0x00fe01] = {
		{ abbreviation, "VS2" };
	};
	[0x00fe02] = {
		{ abbreviation, "VS3" };
	};
	[0x00fe03] = {
		{ abbreviation, "VS4" };
	};
	[0x00fe04] = {
		{ abbreviation, "VS5" };
	};
	[0x00fe05] = {
		{ abbreviation, "VS6" };
	};
	[0x00fe06] = {
		{ abbreviation, "VS7" };
	};
	[0x00fe07] = {
		{ abbreviation, "VS8" };
	};
	[0x00fe08] = {
		{ abbreviation, "VS9" };
	};
	[0x00fe09] = {
		{ abbreviation, "VS10" };
	};
	[0x00fe0a] = {
		{ abbreviation, "VS11" };
	};
	[0x00fe0b] = {
		{ abbreviation, "VS12" };
	};
	[0x00fe0c] = {
		{ abbreviation, "VS13" };
	};
	[0x00fe0d] = {
		{ abbreviation, "VS14" };
	};
	[0x00fe0e] = {
		{ abbreviation, "VS15" };
	};
	[0x00fe0f] = {
		{ abbreviation, "VS16" };
	};
	[0x00fe18] = {
		{   correction, "PRESENTATION FORM FOR VERTICAL RIGHT WHITE LENTICULAR BRACKET" };
	};
	[0x00feff] = {
		{    alternate, "BYTE ORDER MARK" };
		{ abbreviation, "BOM" };
		{ abbreviation, "ZWNBSP" };
	};
	[0x0122d4] = {
		{   correction, "CUNEIFORM SIGN NU11 TENU" };
	};
	[0x0122d5] = {
		{   correction, "CUNEIFORM SIGN NU11 OVER NU11 BUR OVER BUR" };
	};
	[0x016e56] = {
		{   correction, "MEDEFAIDRIN CAPITAL LETTER H" };
	};
	[0x016e57] = {
		{   correction, "MEDEFAIDRIN CAPITAL LETTER NG" };
	};
	[0x016e76] = {
		{   correction, "MEDEFAIDRIN SMALL LETTER H" };
	};
	[0x016e77] = {
		{   correction, "MEDEFAIDRIN SMALL LETTER NG" };
	};
	[0x01b001] = {
		{   correction, "HENTAIGANA LETTER E-1" };
	};
	[0x01d0c5] = {
		{   correction, "BYZANTINE MUSICAL SYMBOL FTHORA SKLIRON CHROMA VASIS" };
	};
	[0x0e0100] = {
		{ abbreviation, "VS17" };
	};
	[0x0e0101] = {
		{ abbreviation, "VS18" };
	};
	[0x0e0102] = {
		{ abbreviation, "VS19" };
	};
	[0x0e0103] = {
		{ abbreviation, "VS20" };
	};
	[0x0e0104] = {
		{ abbreviation, "VS21" };
	};
	[0x0e0105] = {
		{ abbreviation, "VS22" };
	};
	[0x0e0106] = {
		{ abbreviation, "VS23" };
	};
	[0x0e0107] = {
		{ abbreviation, "VS24" };
	};
	[0x0e0108] = {
		{ abbreviation, "VS25" };
	};
	[0x0e0109] = {
		{ abbreviation, "VS26" };
	};
	[0x0e010a] = {
		{ abbreviation, "VS27" };
	};
	[0x0e010b] = {
		{ abbreviation, "VS28" };
	};
	[0x0e010c] = {
		{ abbreviation, "VS29" };
	};
	[0x0e010d] = {
		{ abbreviation, "VS30" };
	};
	[0x0e010e] = {
		{ abbreviation, "VS31" };
	};
	[0x0e010f] = {
		{ abbreviation, "VS32" };
	};
	[0x0e0110] = {
		{ abbreviation, "VS33" };
	};
	[0x0e0111] = {
		{ abbreviation, "VS34" };
	};
	[0x0e0112] = {
		{ abbreviation, "VS35" };
	};
	[0x0e0113] = {
		{ abbreviation, "VS36" };
	};
	[0x0e0114] = {
		{ abbreviation, "VS37" };
	};
	[0x0e0115] = {
		{ abbreviation, "VS38" };
	};
	[0x0e0116] = {
		{ abbreviation, "VS39" };
	};
	[0x0e0117] = {
		{ abbreviation, "VS40" };
	};
	[0x0e0118] = {
		{ abbreviation, "VS41" };
	};
	[0x0e0119] = {
		{ abbreviation, "VS42" };
	};
	[0x0e011a] = {
		{ abbreviation, "VS43" };
	};
	[0x0e011b] = {
		{ abbreviation, "VS44" };
	};
	[0x0e011c] = {
		{ abbreviation, "VS45" };
	};
	[0x0e011d] = {
		{ abbreviation, "VS46" };
	};
	[0x0e011e] = {
		{ abbreviation, "VS47" };
	};
	[0x0e011f] = {
		{ abbreviation, "VS48" };
	};
	[0x0e0120] = {
		{ abbreviation, "VS49" };
	};
	[0x0e0121] = {
		{ abbreviation, "VS50" };
	};
	[0x0e0122] = {
		{ abbreviation, "VS51" };
	};
	[0x0e0123] = {
		{ abbreviation, "VS52" };
	};
	[0x0e0124] = {
		{ abbreviation, "VS53" };
	};
	[0x0e0125] = {
		{ abbreviation, "VS54" };
	};
	[0x0e0126] = {
		{ abbreviation, "VS55" };
	};
	[0x0e0127] = {
		{ abbreviation, "VS56" };
	};
	[0x0e0128] = {
		{ abbreviation, "VS57" };
	};
	[0x0e0129] = {
		{ abbreviation, "VS58" };
	};
	[0x0e012a] = {
		{ abbreviation, "VS59" };
	};
	[0x0e012b] = {
		{ abbreviation, "VS60" };
	};
	[0x0e012c] = {
		{ abbreviation, "VS61" };
	};
	[0x0e012d] = {
		{ abbreviation, "VS62" };
	};
	[0x0e012e] = {
		{ abbreviation, "VS63" };
	};
	[0x0e012f] = {
		{ abbreviation, "VS64" };
	};
	[0x0e0130] = {
		{ abbreviation, "VS65" };
	};
	[0x0e0131] = {
		{ abbreviation, "VS66" };
	};
	[0x0e0132] = {
		{ abbreviation, "VS67" };
	};
	[0x0e0133] = {
		{ abbreviation, "VS68" };
	};
	[0x0e0134] = {
		{ abbreviation, "VS69" };
	};
	[0x0e0135] = {
		{ abbreviation, "VS70" };
	};
	[0x0e0136] = {
		{ abbreviation, "VS71" };
	};
	[0x0e0137] = {
		{ abbreviation, "VS72" };
	};
	[0x0e0138] = {
		{ abbreviation, "VS73" };
	};
	[0x0e0139] = {
		{ abbreviation, "VS74" };
	};
	[0x0e013a] = {
		{ abbreviation, "VS75" };
	};
	[0x0e013b] = {
		{ abbreviation, "VS76" };
	};
	[0x0e013c] = {
		{ abbreviation, "VS77" };
	};
	[0x0e013d] = {
		{ abbreviation, "VS78" };
	};
	[0x0e013e] = {
		{ abbreviation, "VS79" };
	};
	[0x0e013f] = {
		{ abbreviation, "VS80" };
	};
	[0x0e0140] = {
		{ abbreviation, "VS81" };
	};
	[0x0e0141] = {
		{ abbreviation, "VS82" };
	};
	[0x0e0142] = {
		{ abbreviation, "VS83" };
	};
	[0x0e0143] = {
		{ abbreviation, "VS84" };
	};
	[0x0e0144] = {
		{ abbreviation, "VS85" };
	};
	[0x0e0145] = {
		{ abbreviation, "VS86" };
	};
	[0x0e0146] = {
		{ abbreviation, "VS87" };
	};
	[0x0e0147] = {
		{ abbreviation, "VS88" };
	};
	[0x0e0148] = {
		{ abbreviation, "VS89" };
	};
	[0x0e0149] = {
		{ abbreviation, "VS90" };
	};
	[0x0e014a] = {
		{ abbreviation, "VS91" };
	};
	[0x0e014b] = {
		{ abbreviation, "VS92" };
	};
	[0x0e014c] = {
		{ abbreviation, "VS93" };
	};
	[0x0e014d] = {
		{ abbreviation, "VS94" };
	};
	[0x0e014e] = {
		{ abbreviation, "VS95" };
	};
	[0x0e014f] = {
		{ abbreviation, "VS96" };
	};
	[0x0e0150] = {
		{ abbreviation, "VS97" };
	};
	[0x0e0151] = {
		{ abbreviation, "VS98" };
	};
	[0x0e0152] = {
		{ abbreviation, "VS99" };
	};
	[0x0e0153] = {
		{ abbreviation, "VS100" };
	};
	[0x0e0154] = {
		{ abbreviation, "VS101" };
	};
	[0x0e0155] = {
		{ abbreviation, "VS102" };
	};
	[0x0e0156] = {
		{ abbreviation, "VS103" };
	};
	[0x0e0157] = {
		{ abbreviation, "VS104" };
	};
	[0x0e0158] = {
		{ abbreviation, "VS105" };
	};
	[0x0e0159] = {
		{ abbreviation, "VS106" };
	};
	[0x0e015a] = {
		{ abbreviation, "VS107" };
	};
	[0x0e015b] = {
		{ abbreviation, "VS108" };
	};
	[0x0e015c] = {
		{ abbreviation, "VS109" };
	};
	[0x0e015d] = {
		{ abbreviation, "VS110" };
	};
	[0x0e015e] = {
		{ abbreviation, "VS111" };
	};
	[0x0e015f] = {
		{ abbreviation, "VS112" };
	};
	[0x0e0160] = {
		{ abbreviation, "VS113" };
	};
	[0x0e0161] = {
		{ abbreviation, "VS114" };
	};
	[0x0e0162] = {
		{ abbreviation, "VS115" };
	};
	[0x0e0163] = {
		{ abbreviation, "VS116" };
	};
	[0x0e0164] = {
		{ abbreviation, "VS117" };
	};
	[0x0e0165] = {
		{ abbreviation, "VS118" };
	};
	[0x0e0166] = {
		{ abbreviation, "VS119" };
	};
	[0x0e0167] = {
		{ abbreviation, "VS120" };
	};
	[0x0e0168] = {
		{ abbreviation, "VS121" };
	};
	[0x0e0169] = {
		{ abbreviation, "VS122" };
	};
	[0x0e016a] = {
		{ abbreviation, "VS123" };
	};
	[0x0e016b] = {
		{ abbreviation, "VS124" };
	};
	[0x0e016c] = {
		{ abbreviation, "VS125" };
	};
	[0x0e016d] = {
		{ abbreviation, "VS126" };
	};
	[0x0e016e] = {
		{ abbreviation, "VS127" };
	};
	[0x0e016f] = {
		{ abbreviation, "VS128" };
	};
	[0x0e0170] = {
		{ abbreviation, "VS129" };
	};
	[0x0e0171] = {
		{ abbreviation, "VS130" };
	};
	[0x0e0172] = {
		{ abbreviation, "VS131" };
	};
	[0x0e0173] = {
		{ abbreviation, "VS132" };
	};
	[0x0e0174] = {
		{ abbreviation, "VS133" };
	};
	[0x0e0175] = {
		{ abbreviation, "VS134" };
	};
	[0x0e0176] = {
		{ abbreviation, "VS135" };
	};
	[0x0e0177] = {
		{ abbreviation, "VS136" };
	};
	[0x0e0178] = {
		{ abbreviation, "VS137" };
	};
	[0x0e0179] = {
		{ abbreviation, "VS138" };
	};
	[0x0e017a] = {
		{ abbreviation, "VS139" };
	};
	[0x0e017b] = {
		{ abbreviation, "VS140" };
	};
	[0x0e017c] = {
		{ abbreviation, "VS141" };
	};
	[0x0e017d] = {
		{ abbreviation, "VS142" };
	};
	[0x0e017e] = {
		{ abbreviation, "VS143" };
	};
	[0x0e017f] = {
		{ abbreviation, "VS144" };
	};
	[0x0e0180] = {
		{ abbreviation, "VS145" };
	};
	[0x0e0181] = {
		{ abbreviation, "VS146" };
	};
	[0x0e0182] = {
		{ abbreviation, "VS147" };
	};
	[0x0e0183] = {
		{ abbreviation, "VS148" };
	};
	[0x0e0184] = {
		{ abbreviation, "VS149" };
	};
	[0x0e0185] = {
		{ abbreviation, "VS150" };
	};
	[0x0e0186] = {
		{ abbreviation, "VS151" };
	};
	[0x0e0187] = {
		{ abbreviation, "VS152" };
	};
	[0x0e0188] = {
		{ abbreviation, "VS153" };
	};
	[0x0e0189] = {
		{ abbreviation, "VS154" };
	};
	[0x0e018a] = {
		{ abbreviation, "VS155" };
	};
	[0x0e018b] = {
		{ abbreviation, "VS156" };
	};
	[0x0e018c] = {
		{ abbreviation, "VS157" };
	};
	[0x0e018d] = {
		{ abbreviation, "VS158" };
	};
	[0x0e018e] = {
		{ abbreviation, "VS159" };
	};
	[0x0e018f] = {
		{ abbreviation, "VS160" };
	};
	[0x0e0190] = {
		{ abbreviation, "VS161" };
	};
	[0x0e0191] = {
		{ abbreviation, "VS162" };
	};
	[0x0e0192] = {
		{ abbreviation, "VS163" };
	};
	[0x0e0193] = {
		{ abbreviation, "VS164" };
	};
	[0x0e0194] = {
		{ abbreviation, "VS165" };
	};
	[0x0e0195] = {
		{ abbreviation, "VS166" };
	};
	[0x0e0196] = {
		{ abbreviation, "VS167" };
	};
	[0x0e0197] = {
		{ abbreviation, "VS168" };
	};
	[0x0e0198] = {
		{ abbreviation, "VS169" };
	};
	[0x0e0199] = {
		{ abbreviation, "VS170" };
	};
	[0x0e019a] = {
		{ abbreviation, "VS171" };
	};
	[0x0e019b] = {
		{ abbreviation, "VS172" };
	};
	[0x0e019c] = {
		{ abbreviation, "VS173" };
	};
	[0x0e019d] = {
		{ abbreviation, "VS174" };
	};
	[0x0e019e] = {
		{ abbreviation, "VS175" };
	};
	[0x0e019f] = {
		{ abbreviation, "VS176" };
	};
	[0x0e01a0] = {
		{ abbreviation, "VS177" };
	};
	[0x0e01a1] = {
		{ abbreviation, "VS178" };
	};
	[0x0e01a2] = {
		{ abbreviation, "VS179" };
	};
	[0x0e01a3] = {
		{ abbreviation, "VS180" };
	};
	[0x0e01a4] = {
		{ abbreviation, "VS181" };
	};
	[0x0e01a5] = {
		{ abbreviation, "VS182" };
	};
	[0x0e01a6] = {
		{ abbreviation, "VS183" };
	};
	[0x0e01a7] = {
		{ abbreviation, "VS184" };
	};
	[0x0e01a8] = {
		{ abbreviation, "VS185" };
	};
	[0x0e01a9] = {
		{ abbreviation, "VS186" };
	};
	[0x0e01aa] = {
		{ abbreviation, "VS187" };
	};
	[0x0e01ab] = {
		{ abbreviation, "VS188" };
	};
	[0x0e01ac] = {
		{ abbreviation, "VS189" };
	};
	[0x0e01ad] = {
		{ abbreviation, "VS190" };
	};
	[0x0e01ae] = {
		{ abbreviation, "VS191" };
	};
	[0x0e01af] = {
		{ abbreviation, "VS192" };
	};
	[0x0e01b0] = {
		{ abbreviation, "VS193" };
	};
	[0x0e01b1] = {
		{ abbreviation, "VS194" };
	};
	[0x0e01b2] = {
		{ abbreviation, "VS195" };
	};
	[0x0e01b3] = {
		{ abbreviation, "VS196" };
	};
	[0x0e01b4] = {
		{ abbreviation, "VS197" };
	};
	[0x0e01b5] = {
		{ abbreviation, "VS198" };
	};
	[0x0e01b6] = {
		{ abbreviation, "VS199" };
	};
	[0x0e01b7] = {
		{ abbreviation, "VS200" };
	};
	[0x0e01b8] = {
		{ abbreviation, "VS201" };
	};
	[0x0e01b9] = {
		{ abbreviation, "VS202" };
	};
	[0x0e01ba] = {
		{ abbreviation, "VS203" };
	};
	[0x0e01bb] = {
		{ abbreviation, "VS204" };
	};
	[0x0e01bc] = {
		{ abbreviation, "VS205" };
	};
	[0x0e01bd] = {
		{ abbreviation, "VS206" };
	};
	[0x0e01be] = {
		{ abbreviation, "VS207" };
	};
	[0x0e01bf] = {
		{ abbreviation, "VS208" };
	};
	[0x0e01c0] = {
		{ abbreviation, "VS209" };
	};
	[0x0e01c1] = {
		{ abbreviation, "VS210" };
	};
	[0x0e01c2] = {
		{ abbreviation, "VS211" };
	};
	[0x0e01c3] = {
		{ abbreviation, "VS212" };
	};
	[0x0e01c4] = {
		{ abbreviation, "VS213" };
	};
	[0x0e01c5] = {
		{ abbreviation, "VS214" };
	};
	[0x0e01c6] = {
		{ abbreviation, "VS215" };
	};
	[0x0e01c7] = {
		{ abbreviation, "VS216" };
	};
	[0x0e01c8] = {
		{ abbreviation, "VS217" };
	};
	[0x0e01c9] = {
		{ abbreviation, "VS218" };
	};
	[0x0e01ca] = {
		{ abbreviation, "VS219" };
	};
	[0x0e01cb] = {
		{ abbreviation, "VS220" };
	};
	[0x0e01cc] = {
		{ abbreviation, "VS221" };
	};
	[0x0e01cd] = {
		{ abbreviation, "VS222" };
	};
	[0x0e01ce] = {
		{ abbreviation, "VS223" };
	};
	[0x0e01cf] = {
		{ abbreviation, "VS224" };
	};
	[0x0e01d0] = {
		{ abbreviation, "VS225" };
	};
	[0x0e01d1] = {
		{ abbreviation, "VS226" };
	};
	[0x0e01d2] = {
		{ abbreviation, "VS227" };
	};
	[0x0e01d3] = {
		{ abbreviation, "VS228" };
	};
	[0x0e01d4] = {
		{ abbreviation, "VS229" };
	};
	[0x0e01d5] = {
		{ abbreviation, "VS230" };
	};
	[0x0e01d6] = {
		{ abbreviation, "VS231" };
	};
	[0x0e01d7] = {
		{ abbreviation, "VS232" };
	};
	[0x0e01d8] = {
		{ abbreviation, "VS233" };
	};
	[0x0e01d9] = {
		{ abbreviation, "VS234" };
	};
	[0x0e01da] = {
		{ abbreviation, "VS235" };
	};
	[0x0e01db] = {
		{ abbreviation, "VS236" };
	};
	[0x0e01dc] = {
		{ abbreviation, "VS237" };
	};
	[0x0e01dd] = {
		{ abbreviation, "VS238" };
	};
	[0x0e01de] = {
		{ abbreviation, "VS239" };
	};
	[0x0e01df] = {
		{ abbreviation, "VS240" };
	};
	[0x0e01e0] = {
		{ abbreviation, "VS241" };
	};
	[0x0e01e1] = {
		{ abbreviation, "VS242" };
	};
	[0x0e01e2] = {
		{ abbreviation, "VS243" };
	};
	[0x0e01e3] = {
		{ abbreviation, "VS244" };
	};
	[0x0e01e4] = {
		{ abbreviation, "VS245" };
	};
	[0x0e01e5] = {
		{ abbreviation, "VS246" };
	};
	[0x0e01e6] = {
		{ abbreviation, "VS247" };
	};
	[0x0e01e7] = {
		{ abbreviation, "VS248" };
	};
	[0x0e01e8] = {
		{ abbreviation, "VS249" };
	};
	[0x0e01e9] = {
		{ abbreviation, "VS250" };
	};
	[0x0e01ea] = {
		{ abbreviation, "VS251" };
	};
	[0x0e01eb] = {
		{ abbreviation, "VS252" };
	};
	[0x0e01ec] = {
		{ abbreviation, "VS253" };
	};
	[0x0e01ed] = {
		{ abbreviation, "VS254" };
	};
	[0x0e01ee] = {
		{ abbreviation, "VS255" };
	};
	[0x0e01ef] = {
		{ abbreviation, "VS256" };
	};
}
