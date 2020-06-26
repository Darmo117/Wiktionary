-- Data used to generate the names of characters in the Hangul Syllables block
-- (U+AC00 to U+D7A3).
local Hangul = {}

-- The following leads, vowels, and trails come from here:
-- http://www.unicode.org/Public/UNIDATA/Jamo.txt
Hangul.leads = {
	[0] = "G", "GG", "N", "D", "DD", "R", "M", "B", "BB", "S", "SS",
	"", "J", "JJ", "C", "K", "T", "P", "H"
}
-- not actually used:
Hangul.lead_count = #Hangul.leads + 1

Hangul.vowels = {
	[0] = "A", "AE", "YA", "YAE", "EO", "E", "YEO", "YE", "O", "WA",
	"WAE", "OE", "YO", "U", "WEO", "WE", "WI", "YU", "EU", "YI",
	"I"
}
Hangul.vowel_count = #Hangul.vowels + 1

Hangul.trails = {
	[0] = "", "G", "GG", "GS", "N", "NJ", "NH", "D", "L", "LG", "LM", "LB",
	"LS", "LT", "LP", "LH", "M", "B", "BS", "S", "SS", "NG", "J", "C", "K",
	"T", "P", "H"
}
Hangul.trail_count = #Hangul.trails + 1

--For the term "final", see [[Syllable#Chinese model]].
Hangul.final_count = Hangul.vowel_count * Hangul.trail_count

return Hangul
