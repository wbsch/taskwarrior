#!/usr/bin/env python2.7
# -*- coding: utf-8 -*-
###############################################################################
#
# Copyright 2006 - 2015, Paul Beckingham, Federico Hernandez.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# http://www.opensource.org/licenses/mit-license.php
#
###############################################################################

import sys
import os
import re
import unittest
# Ensure python finds the local simpletap module
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from basetest import TestCase
from basetest.utils import CURRENT_DIR, run_cmd_wait, run_cmd_wait_nofail

CALC = os.path.abspath(os.path.join(CURRENT_DIR, "..", "..", "src/calc"))


@unittest.skipIf(not os.path.isfile(CALC),
                 "calc binary not available in {0}".format(CALC))
class TestCalc(TestCase):
    def test_regular_math(self):
        """regular math"""
        code, out, err = run_cmd_wait((CALC, "--debug", "12 * 3600 + 34 * 60 + 56"))

        self.assertIn("Eval literal number ↑'12'", out)
        self.assertIn("Eval literal number ↑'3600'", out)
        self.assertIn("Eval literal number ↑'60'", out)
        self.assertIn("Eval literal number ↑'56'", out)
        self.assertRegexpMatches(out, re.compile("^45296$", re.MULTILINE))
        self.assertNotIn("Error", out)
        self.assertNotIn("Error", err)

    def test_postfix_math(self):
        """postfix math"""
        code, out, err = run_cmd_wait((CALC, "--debug", "--postfix", "12 3600 * 34 60 * 56 + +"))

        self.assertIn("Eval literal number ↑'12'", out)
        self.assertIn("Eval literal number ↑'3600'", out)
        self.assertIn("Eval literal number ↑'60'", out)
        self.assertIn("Eval literal number ↑'56'", out)
        self.assertRegexpMatches(out, re.compile("^45296$", re.MULTILINE))
        self.assertNotIn("Error", out)
        self.assertNotIn("Error", err)

    def test_negative_numbers(self):
        """regular math with negative numbers"""
        code, out, err = run_cmd_wait((CALC, "--debug", "2- -3"))

        self.assertIn("Eval literal number ↑'2'", out)
        self.assertIn("Eval _neg_ ↓'3' → ↑'-3'", out)
        self.assertIn("Eval literal number ↑'2'", out)
        self.assertRegexpMatches(out, re.compile("^5$", re.MULTILINE))
        self.assertNotIn("Error", out)
        self.assertNotIn("Error", err)

    def test_help(self):
        """help"""
        code, out, err = run_cmd_wait_nofail((CALC, "--help"))

        self.assertIn("Usage:", out)
        self.assertIn("Options:", out)
        self.assertGreaterEqual(code, 1)

    def test_version(self):
        """version"""
        code, out, err = run_cmd_wait_nofail((CALC, "--version"))

        self.assertRegexpMatches(out, "calc \d\.\d+\.\d+")
        self.assertIn("Copyright", out)
        self.assertGreaterEqual(code, 1)


if __name__ == "__main__":
    from simpletap import TAPTestRunner
    unittest.main(testRunner=TAPTestRunner())

# vim: ai sts=4 et sw=4
