
---
## June 27, 2025 - Release 1.0.2

### New Features:
- Added a setting to hide the windows title bar on desktop platforms. This is
  useful for improving the appearance under Linux/Wayland.

### Updates:
- Added the decibel-milliwatt (dBm) power unit.
- Added the gas mark temperature unit for old UK gas stoves.
- Several EV efficiency units were added: miles per kWh, miles per gallon
  equiv, and kilowatt-hours per 100 km.
- Updated the versions of several libraries used to build ConvertAll.
- Updated the list of dependencies in the Linux install script.

---
## March 23, 2024 - Release 1.0.1

### Updates:
- Improved the speed and responsiveness of the Fraction Conversion tool.

### Bug Fixes:
- Fix a problem entering units with exponents that are not whole numbers.

---
## November 26, 2023 - Release 1.0.0

### New Features:
- ConvertAll has been rewritten in Dart using the Flutter framework. It now has
  a cleaner-looking interface. A single code base can run on Linux, Windows,
  Android and on the web.
- An older ConvertAll version is available on the Downloads page for those that
  need language translations.

### Updates:
- The kip (kilopound force) unit was added.
- The mm H2O pressure unit was added.
- Added the MGD and MLD units to cover large flow rates.
- Added the Bohr radius nuclear size unit.
- The dunam land area unit was added.
- Added the teenth unit (drug slang).
- Many SI prefixes were added so they can be combined with any other unit using
  multiplication. For example, "tera * watt" can be entered for terawatts.

---
## March 22, 2020 - Release 0.8.0

### New Features:
- Added a separate base conversion dialog to convert between different base
  numbering systems. It converts from/to decimal, hexadecimal, octal and binary
  bases.
- Added a separate fraction conversion dialog to convert from decimal to
  fractional numbers. It provides a list of fractions in order of increasing
  accuracy.
- A GUI font selection button was added to the Options dialog. This allows
  larger fonts to be used for high resolution displays.
- A new GUI color setting dialog was added to the Options dialog. It allows a
  dark theme to be selected, or colors can be selected individually.

### Updates:
- Added the Beaufort wind speed unit.
- R-value thermal resistance units were added.
- The diopter/dioptre optical power unit was added.
- Added the rydberg and hartree energy units.
- Added the Planck constant as a unit.
- Slightly adjusted the conversion value of the atomic mass unit (amu) and
  added the dalton synonym.
- Slightly adjusted the conversion value of the astronomical (au) and the
  parsec units.
- Add Swedish translation (thanks to Ake Engelbrektson).
- Add Catalan translation (thanks to Pere Orga).
- Update the libraries used to build the Windows binaries to Python 3.8 and
  Qt/PyQt 5.14.

### Bug Fixes:
- Fixed a problem with the ConvertAll window being positioned off the screen
  after major changes in resolution when using external monitors.
- Clarified the labels for several power-of-10 data units (KB, MB, etc.) to
  show as "SI standard" rather than "IEC standard".

---
## July 4, 2018 - Release 0.7.5

### Updates:
- Updated the Russian GUI and unit translation (thanks to Ivan / vantu5z).

### Bug Fixes:
- Fix the tab sequence to allow tabbing between the unit edit boxes and the
  numeric edit boxes.

---
## April 4, 2018 - Release 0.7.4

### New Features:
- Added a desktop file to the Linux version to provide menu entries.
- Added an option to disable saving the window position and size at startup.

### Updates:
- Added US drill bit gauge sizes as a non-linear unit.
- Added gigabit and terabit data units.
- Adjusted the liter per 100 km fuel economy unit definition in the German
  translation to match the English version.

---
## October 15, 2017 - Release 0.7.3

### Updates:
- Added the boiler horsepower unit.

### Bug Fixes:
- Fixed a crash if a zero value is entered when the engineering notation option
  is enabled.
- Fixed an initialization issue that caused problems with some versions of
  Python.

---
## February 20, 2017 - Release 0.7.2

### Bug Fixes:
- Fix a crash due to an overflow error whem typing part of an exponent in the
  denominator of the second unit.
- Avoid flipping the preceeding operator between multiplication and division as
  a unit exponent of 0.5 is typed.

---
## February 4, 2017 - Release 0.7.1 (Linux only)

### Bug Fixes:
- Replaced outdated dependency checks in the Linux installer - it now runs
  checks for Qt5 libraries.
- Fixed a timing issue in the Linux installer so that byte-compiled files do
  not have old timestamps.

---
## January 8, 2017 - JavaScript Version - Release 0.1.1
- Announcing a new online version of ConvertAll that is written in JavaScript.
  See http://convertall.bellz.org/js/ to try it out. It will be developed in
  parallel with the regular PyQt version.


---
## January 8, 2017 - Release 0.7.0

### New Features:
- Dual unit lists have been replaced with a single list that works with the
  active unit line editor.
- As a unit is typed, the listing of units is reduced to only include units
  that match the typed words.
- The unit list can be sorted by clicking on the column headings.
- The unit list can be filtered to only show units of a certain type.
- Simple unit exponents (positive 2 and 3) can be typed with just the number
  (leaving out the "^" character).
- Now permits decimals to be entered for unit exponents, supporting roots of
  units.
- ConvertAll has been ported from the Qt4 to the Qt5 library.

### Updates:
- Since the main unit list can now be searched, sorted and filtered, the Unit
  Finder Dialog has been removed.
- Added the British Std Wire Gauge non-linear unit.
- Added the ton imnperial unit.
- Added the cable nautical unit.
- Added the MBH (1000 Btu/hr) unit.
- Added Cape foot, square perch and rood units.

### Bug Fixes:
- Corrected some unit definitions in the French translation, including
  avogadro's number, lambert, poise and the gravitational constant.

---
## September 10, 2015 - Release 0.6.1

### New Features:
- Added an option to output results in engineering notation (a version of
  scientific notation with exponents divisible by three).
- A Russian translation was added. Thanks to vantu5z for translating.

### Updates:
- Added the dram mass unit.
- Added the fluid dram and the minim volume units, in both US and Imperial
  versions.
- Added the smoot length unit.
- Added "dm" as an abbreviation for the decimeter length unit.
- Added "avoirdupois" to the comment column for applicable mass and weight
  units.
- Added "fresh water" to the comment column for applicable depth-based pressure
  units.
- The German translation was updated. Thanks to Thomas Helmke for translating.
- Added some MSVC runtime DLL files to the Windows installers to avoid problems
  on PCs that do not already have them.
- Clarified some dependency checker error messages in the Linux installer.

### Bug Fixes:
- Fixed an error in the unit data formula for the AWG area unit.
- Changed the value of the caliber unit to be equivalent to inches (typical
  written usage), not hundredths of an inch (typical verbal usage).

---
## February 1, 2014 - Release 0.6.0

### New Features:
- ConvertAll has been ported from Python 2 to Python 3. This porting includes
  some code cleanup.
- Added an option to automatically load the last used units at startup.
- Added an introductory tip dialog box that explains combined units. There is
  also an option to hide this dialog.
- There is an additional Windows installer for users without administrator
  rights and for portable installations.
- Added a Windows installer option to add a config file to the program's
  directory for portable installations. If that file is present, no config
  files will be written to users' directories.

### Updates:
- The Windows binaries are built using more recent Python, Qt and PyQt
  libraries.
- The user interface and unit data language translations are now included in
  the main installation files.
- Added the long ton unit (Imperial version of the ton).
- Added the kilopond unit as a synonym of kilogram-force.
- Added the micron of Hg pressure unit.
- Added the lunar distance (LD) astronomical distance unit.
- Added the rack unit (height of an electrical rack).
- Added the versta Russian length unit.

### Bug Fixes:
- Fixed the operation of the "Clear" button in the Unit Finder dialog.
- Fixed a problem with the definition of the BTU unit in the French
  translation.

---
## November 2, 2011 - Release 0.5.2

### Updates:
- Added the microliter volume unit.
- Added the galileo acceleration unit.
- Added the stremma land area unit.

### Bug Fixes:
- Changed the method of identifying a "unitless" portion of a unit to avoid
  falsely reporting incompatibility between some units when using language
  translations.

---
## April 12, 2011 - Translation Update 0.5.1b

### Bug Fixes:
- Fixed inconsistencies in all three unit data translations (French, German and
  Spanish) that caused some unit conversions to fail.

---
## March 31, 2011 - Release 0.5.1

### Updates:
- Added the link length unit.
- Added US survey variations of the mile and chain length units.
- Added the centigray radiation dose unit.
- Use DOS newline characters in the Windows version of the unit data file for
  easier editing by users.

### Bug Fixes:
- Fixed incorrect definition of the rad radiation dose unit (it was off by a
  factor of 10).

---
## May 2, 2010 - Translation Update 0.5.0b

### Updates:
- Added a Spanish translation to the 0.5.0b version of the translations. The
  French and German translations remain unchanged.

---
## April 23, 2010 - Release 0.5.0

### New Features:
- Multiplication and division operators now have the same precedence. In
  previous versions of ConvertAll, a series of units after a division symbol
  were assumed to be in the denominator. Now, a division operator only affects
  the unit (or the unit group in parenthesis) immediately after the operator.
- Parenthesis are now supported to group units in the denominator of a combined
  unit. For example, ""m / sec / kg" can also be entered as "m / (sec * kg)".
  "Recent Unit" buttons have been added that open a menu of recently used units
  and unit combinations. A unit selected from the menu will replace the current
  unit combination. There is also a new option dialog entry that controls the
  maximum length of this menu.

### Updates:
- Added the tonne force metric force unit.
- Added hundredweight long and hundredweight short mass units.
- Added an American Wire Gauge (AWG) area unit in addition to the existing AWG
  diameter unit.
- Added the tonne oil equivalent and the tonne coal equivalent energy units.
- Added the ton refrigeration power unit.
- Added the darcy and millidarcy permeability units.
- French and German translations have been added for the user interface and the
  unit data. To use them, download and install the "convertall-i18n..." file
  for your platform (in addition to installing the standard ConvertAll
  package).

### Bug Fixes:
- Fixed problems with running in the command line mode from Linux consoles
  without X11 present.

---
## September 24, 2009 - Release 0.4.3

### New Features:
- Prepared ConvertAll for translation efforts by properly handling Unicode
  characters in unit data and by marking internal program strings for
  translation. Volunteers for translating ConvertAll into other languages are
  welcome.

### Updates:
- Added solar mass and pennyweight mass units.
- Added therm and thermie energy units.
- Added gauss and maxwell magnetic units.
- Added the US survey foot length unit.
- Added the mpg imp mileage unit.
- Changed the value of the point unit from the old American point to the more
  modern desktop publishing point.

### Bug Fixes:
- A critical QString conversion bug that caused ConvertAll to not run with the
  latest version of PyQt (4.5.4) was fixed.
- Command line quiet mode was fixed to avoid an interactive prompt when bad
  unit data is entered.

---
## May 28, 2008 - Release 0.4.2

### Updates:
- Added the "liter per 100 km" unit for fuel consumption.

### Bug Fixes:
- Changed the "mach" unit from 331.46 m/s to 340.29 m/s. It is now correct for
  STP conditions (15 degrees C). The previous value was for 0 degrees C.
- Fixed a bug that could hide messages about errors in a manually edited unit
  data file.

---
## January 22, 2008 - Release 0.4.1

### New Features:
- An optional command line mode was added to do conversions without the
  graphical interface. Enter the command ("convertall"), the number, the from
  unit and the to unit (separated by spaces) to do the conversion. For a more
  detailed list of options, enter "convertall -h" on the command line.

### Updates:
- The icon used for ConvertAll has been updated. Thanks to Ricardo Berlasso for
  the new artwork.
- Alternate units have been added for kilobyte, megabyte, etc., marked "IEC
  std". These convert using powers of 10, rather than powers of 2.
- Troy pounds and troy ounces have been added.
- Gigapascal, hectopascal and megabar have been added.
- Hogshead units for wine and beer have been added.
- The Swedish mil unit of distance has been added.
- The Thai rai and ngaan units of land area have been added.

---
## October 5, 2006 - Release 0.4.0

### New Features:
- ConvertAll was ported to the Qt4 library. This involved a significant rewrite
  of the code. The previous versions used Qt3.x on Linux and Qt2.3 on Windows.
  Benefits include updated widgets and removal of the non-commercial license
  exception in Windows.

### Updates:
- On Windows, the ConvertAll.ini file has been moved from the installation
  directory to a location under the "Documents and Settings" folder. This
  avoids problems on multi-user systems and for users with limited access
  rights.

---
## October 5, 2006 - Release 0.3.2

### Updates:
- Added Imperial (UK) gallons, quarts, pints and fluid ounces.
- Added gigagram and teragram units.
- Added the pound-mole unit and clarified that the existing mole is a
  gram-mole.

---
## February 14, 2005 - Release 0.3.1

### Updates:
- Added the decare unit for land area.
- The Linux installer has been updated to be more robust and give more install
  directory options.

### Bug Fixes:
- The barn unit, used in particle physics, was corrected. It had been
  incorrectly listed as a length unit instead of an area unit.

---
## March 11, 2004 - Release 0.3.0

### New Features:
- A unit finder window was added to allow the unit list to be filtered and
  searched.
- The size and position of the main and finder windows are now saved at exit.
- A new option allows the operator text entry buttons (x, /, ^2, ^3 and Clear
  Unit) to be hidden.
- An install program has been added for windows.

### Bug Fixes:
- Fixed Linux install script problems with certain versions of Python.

---
## November 18, 2003 - Release 0.2.4

### Updates:
- Keyboard shortcuts and tab-focus order for the main dialog have been
  improved.
- An install script was added for Linux and Unix systems.
- The windows build now uses Python version 2.3 and PyQt version 3.8.

---
## March 24, 2003 - Release 0.2.3

### Updates:
- When an expression using division is entered for the number to be converted,
  floating point division is now used even if the entries are integers (Python
  2.2 or greater only).
- Mouse wheels are now supported in the unit lists.
- Icon files are now provided with the distribution files.

---
## May 28, 2002 - Release 0.2.2a

### Bug Fixes:
- A fix of the Windows binary only. Fixes major problems by upgrading the
  library version to PyQt 3.2.4.

---
## May 16, 2002 - Release 0.2.2

### Updates:
- ConvertAll has been ported to Qt 3. It now works with both Qt 2.x and 3.x
  using the same source code.
- The help/readme file has been rewritten and now includes section links.
- The binaries for windows have been updated to Python 2.2 and PyQt 3.2 (but
  are still using Qt 2.3 Non-commercial).

---
## March 19, 2002 - Website Update
- This website now looks a little better. Hopefully, it's more user-friendly,
  too.
- Stay tuned - I'll soon be porting these programs to use PyQt with Qt 3.0.

---
## September 17, 2001 - Release 0.2.1

### Bug Fixes:
- Some window captions and icons were corrected.
- A window maximizing bug was fixed.

---
## August 20, 2001 - Release 0.2.0

### New Features:
- A major rewrite was done of the conversion engine.
- A new data file format makes it easier to add and verify units.
- The unit name and abbreviation are now listed separately for better sorting
  and searching.
- Entering of units has been improved by changing operator precedence, by
  ignoring spaces and plurals, and by changing the partial selection list
  highlight.
- An expression can now be used for the number to be converted.

### Updates:
- Many additional units were added to the database.
- For MS Windows users, the binary files were upgraded to PyQt Version 2.5.

---
## August 10, 2001 - Release 0.1.1

### New Features:
- Added color controls to the options dialog.

### Updates:
- The convertall.ini file on windows was moved to the program directory.

### Bug Fixes:
- Fixed problems with using the same unit twice in a combined unit.
- Fixed an occasional shutdown when auto-completing.
- Fixed a problem with the updating of the unit label.

---
## July 28, 2001 - Release 0.1.0
- Initial release.
