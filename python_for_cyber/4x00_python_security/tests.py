#!/usr/bin/env python3

import unittest
from utils import validate_line, check_policy, hash_password


calc_hash = "a4dd5658ec0219465b705ea7c7435d9786a3c66d4f448cabd7488dabceafb699"


class TestLineValidation(unittest.TestCase):
    def test_line_format(self):
        result = validate_line("admin@company.corp:password")
        self.assertTrue(result)


class TestPasswordPolicy(unittest.TestCase):
    def test_is_password_weak(self):
        result = check_policy("password")
        self.assertEqual(result, 'WEAK')


class TestHashingPassword(unittest.TestCase):
    def test_is_hashing_ok(self):
        result = hash_password("password", "123456")
        self.assertEqual(result, calc_hash)


if __name__ == "__main__":
    unittest.main()
