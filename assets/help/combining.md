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

The buttons below the unit text boxes can also be used to add operators to the
active unit that is closest to the cursor. The Square and Cube buttons will add
or replace exponents. The Multiply and Divide buttons will add "*" and "/"
operators.

Similarly, clicking on a unit from the list generally replaces the unit nearest
the cursor.

The "Clear Unit" button below the operator buttons may be used to empty the
unit edit window to allow a new unit to be entered.

The "Filter List" button can be used to show only one type of unit in the list.
Note that this doesn't show units that could be combined to form a type.
