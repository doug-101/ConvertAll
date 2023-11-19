---
# Usage
---
## Combining Units
---

The real strength of ConvertAll lies in its ability to combine multiple units.
Simply type the unit names with an '*' or a '/' between them. This allows the
entry of units such as "ft * lbf" or "mi / hr". The '^' symbol may be used for
exponents, such as "ft^3" or "ft * lbm / sec^2". Negative exponents are allowed
for units such as "sec^-1" (per second), but may switch the multiplication or
division symbol ("ft * sec^-2" becomes "ft / sec^2").

Multiplication and division have the same precedence, so they are evaluated
left-to-right. Parenthesis may also be used to group units in the denominator.
So "m / sec / kg" can also be entered as "m / (sec * kg)". The version with
parenthesis is probably less confusing.

Clicking or tapping on a unit from the list generally replaces the unit nearest
the cursor.

The clear unit button in the header (lines with an X) may be used to empty the
unit edit boxes to allow new units to be entered.

The filter List button in the header (funnel image) can be used to show only
one type of unit in the list. Note that this doesn't show units that could be
combined to form a type.
