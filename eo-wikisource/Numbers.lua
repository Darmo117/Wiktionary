local p = {}

local UNITS = {
  "unu", "du", "tri", "kvar", "kvin", "ses", "sep", "ok", "naŭ",
}
local POWERS = {
  "dek", "cent", "mil",
}

function p._formatOrdinal(number, accusative, addHyphens)
  if number > 9999 then
    error("La numero ne povas esti pli granda ol 9999")
  end
  local res = ""
  local power = 1
  local sep = addHyphens and "-" or " "

  while number > 0 do
    local d = number % 10
    if power > 1 then
      res = POWERS[power - 1] .. (res ~= "" and sep or "") .. res
    end
    if d == 1 and power == 1 then
      res = UNITS[1]
    elseif d > 1 then
      res = UNITS[d] .. res
    end
    number = math.floor(number / 10)
    power = power + 1
  end

  return res .. "a" .. (accusative and "n" or "")
end

--- Converts an integer into a roman numeral.
--- @param n number The number to convert.
--- @return string The converted number.
function p._toRomanNumeral(n)
  if n <= 0 then
    error("La nombro devas esti pli granda ol 0!")
  end

  local symbols = {
    "I", "V",
    "X", "L",
    "C", "D",
    "M", "ↁ",
    "ↂ", "ↇ",
    "ↈ",
  }
  local exp = 0;
  local res = "";

  local i = n
  while i > 0 do
    local d = i % 10;
    local unit1 = symbols[exp * 2 + 1];
    local unit5 = symbols[(exp + 1) * 2];
    local unit10 = symbols[(exp + 1) * 2 + 1];
    local str = "";

    if d ~= 0 then
      if d <= 3 then
        for _ = 0, d - 1 do
          str = str .. unit1
        end
      elseif d == 4 then
        str = str .. unit1 .. unit5
      elseif d == 5 then
        str = str .. unit5
      elseif 5 < d and d < 9 then
        str = str .. unit5
        for _ = 0, d - 6 do
          str = str .. unit1
        end
      else
        str = str .. unit1 .. unit10
      end
    end
    res = str .. res;
    i = math.floor(i / 10);
    exp = exp + 1;
  end

  return res;
end

function p.formatOrdinal(frame)
  local value = frame.args[1]
  local addHyphens = frame.args["streko"] ~= nil and frame.args["streko"] ~= ""
  local number, accusative = mw.ustring.match(value, "^(%d+)a(n?)$")
  return p._formatOrdinal(tonumber(number), accusative == "n", addHyphens)
end

function p.toRomanNumeral(frame)
  return p._toRomanNumeral(tonumber(frame.args[1]))
end

return p
