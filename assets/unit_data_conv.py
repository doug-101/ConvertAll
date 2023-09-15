#!/usr/bin/env python3

# unit_data_conv.py, converts ConvertAll's units.dat file to JSON for Flutter.

import sys
import os.path
import re

class UnitAtom():
    def __init__(self, dataStr):
        dataList = dataStr.split('#')
        unitList = dataList.pop(0).split('=', 1)
        self.name = unitList.pop(0).strip()
        self.equiv = ''
        self.fromEqn = ''
        self.toEqn = ''
        if unitList:
            self.equiv = unitList[0].strip()
            if self.equiv.startswith('['):
                match = re.match(r'\[(.*?)\](.*)', self.equiv)
                self.equiv = match.group(1)
                eqn = match.group(2).strip()
                if ';' in eqn:
                    eqn = eqn.replace('**', '^')
                    eqn = eqn.replace('sqrt', 'SQRT')
                    eqn = eqn.replace('pi', 'PI')
                    eqn = eqn.replace('log', 'LOG')
                    self.fromEqn, self.toEqn = eqn.split(';', 1)
                    self.fromEqn = self.fromEqn.strip()
                    self.toEqn = self.toEqn.strip()
                else:
                    eqn = eqn.replace('(', '[')
                    self.fromEqn = eqn.replace(')', ']')
        comments = [comm.strip() for comm in dataList]
        self.unabbrevName = ''
        if comments:
            self.unabbrevName = comments.pop(0)
        self.comment = ''
        if comments:
            self.comment = comments[0]
        self.typeName = ''

    def output(self):
        s = '{{"name":"{0}", "equiv":"{1}", "type":"{2}"'\
                .format(self.name, self.equiv, self.typeName)
        if self.fromEqn:
            s = '{0}, "fromeqn":"{1}"'.format(s, self.fromEqn)
        if self.toEqn:
            s = '{0}, "toeqn":"{1}"'.format(s, self.toEqn)
        if self.unabbrevName:
            s = '{0}, "unabbrev":"{1}"'.format(s, self.unabbrevName)
        if self.comment:
            s = '{0}, "comment":"{1}"'.format(s, self.comment)
        s = '{0}}}'.format(s)
        return s

fileNames = sys.argv[1:]
if not fileNames:
    print('Input data file names must be given on the command line')
    sys.exit(1)

for fileName in fileNames:
    try:
        with open(fileName, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except IOError:
        print('Could not read file: {0}'.format(fileName))
        continue
    for i in range(len(lines)):     # join continuation lines
        delta = 1
        while lines[i].rstrip().endswith('\\'):
            lines[i] = ' '.join([lines[i].rstrip()[:-1].rstrip(),
                                 lines[i+delta].lstrip()])
            lines[i+delta] = ''
            delta += 1
    units = [UnitAtom(line) for line in lines if
             line.split('#', 1)[0].strip()]   # remove comment lines
    typeText = ''
    for unit in units:               # find & set headings
        if unit.name.startswith('['):
            typeText = unit.name[1:-1].strip()
        unit.typeName = typeText
    units = [unit for unit in units if unit.equiv]  # keep valid units
    print(len(units), 'units read')
    lines = [unit.output() for unit in units]
    fileName = os.path.basename(fileName)
    fileName = os.path.splitext(fileName)[0] + '.json'
    try:
        with open(fileName, 'w', encoding='utf-8') as f:
            f.write('[\n')
            f.write(',\n'.join(lines))
            f.write('\n]\n')
    except IOError:
        print('Could not write to file: {0}'.format(fileName))
        continue
