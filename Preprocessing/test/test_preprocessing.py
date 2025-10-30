#!/usr/bin/env python3
"""
Unit Tests for HTRC Preprocessing Pipeline

Tests processing logic without requiring large HTRC files.
Verifies that processing parameters are fixed for reproducibility.
"""

import unittest
import sys
from pathlib import Path

# Add parent directory to path to import preprocessing module
sys.path.insert(0, str(Path(__file__).parent.parent))

# Import functions and constants from preprocessing script
from preprocess_htrc import (
    int_to_roman_lowercase,
    POS_TAGS,
    MIN_WORD_LENGTH,
    MIN_WORD_FREQUENCY,
    GREEK_CORRECTION,
    LIGATURES,
    STOPWORD_FILTERS
)


class TestProcessingParameters(unittest.TestCase):
    """Verify that processing parameters are fixed for reproducibility"""

    def test_pos_tags_fixed(self):
        """POS tags should be exactly 20 specific tags"""
        self.assertEqual(len(POS_TAGS), 20)
        expected_tags = ('NE', 'NN', 'NNP', 'NNPS', 'JJ', 'JJS', 'JJR',
                        'IN', 'DT', 'VB', 'VBP', 'VBZ', 'VBD', 'VBN', 'VBG',
                        'RB', 'RBR', 'RBS', 'RP', 'CC')
        self.assertEqual(POS_TAGS, expected_tags)

    def test_min_word_length_fixed(self):
        """Minimum word length should be 2 characters"""
        self.assertEqual(MIN_WORD_LENGTH, 2)
        self.assertIsInstance(MIN_WORD_LENGTH, int)

    def test_min_word_frequency_fixed(self):
        """Minimum word frequency should be 2 per volume"""
        self.assertEqual(MIN_WORD_FREQUENCY, 2)
        self.assertIsInstance(MIN_WORD_FREQUENCY, int)

    def test_stopword_filters_all_enabled(self):
        """All 8 stopword categories should be enabled"""
        self.assertEqual(len(STOPWORD_FILTERS), 8)
        expected_categories = {
            'cities', 'countries', 'people_names', 'english_stopwords',
            'modern_words', 'continents', 'days_months', 'roman_numerals', 'stems'
        }
        self.assertEqual(set(STOPWORD_FILTERS.keys()), expected_categories)
        # All should be True
        for category, enabled in STOPWORD_FILTERS.items():
            self.assertTrue(enabled, f"Stopword category '{category}' should be enabled")


class TestCharacterCleaning(unittest.TestCase):
    """Test character normalization and cleaning"""

    def test_greek_character_correction(self):
        """Greek characters should be correctly mapped"""
        test_cases = [
            ('º', 'o'),
            ('ª', 'a'),
            ('ſ', 's'),
            ('β', 'b')
        ]
        for greek_char, expected in test_cases:
            result = greek_char.translate(GREEK_CORRECTION)
            self.assertEqual(result, expected,
                           f"Greek char '{greek_char}' should map to '{expected}'")

    def test_greek_correction_in_words(self):
        """Greek corrections should work in full words"""
        test_str = "ºbſerved"  # observed with OCR errors
        result = test_str.translate(GREEK_CORRECTION)
        self.assertEqual(result, "obserbed")

    def test_ligature_replacements(self):
        """Ligatures should be correctly replaced"""
        test_cases = {
            'ﬁnd': 'find',
            'ﬂower': 'flower',
            'ﬀort': 'ffort',
            'ﬅ': 'ft',
            'ﬃ': 'ffi',
            'ﬄ': 'ffl'
        }
        for input_str, expected in test_cases.items():
            result = input_str
            for ligature, replacement in LIGATURES.items():
                result = result.replace(ligature, replacement)
            self.assertEqual(result, expected,
                           f"Ligature in '{input_str}' should become '{expected}'")

    def test_ligatures_count(self):
        """Should have exactly 6 ligature mappings"""
        self.assertEqual(len(LIGATURES), 6)


class TestRomanNumerals(unittest.TestCase):
    """Test Roman numeral generation"""

    def test_basic_roman_numerals(self):
        """Basic Roman numerals should be correct"""
        test_cases = {
            1: 'i',
            5: 'v',
            10: 'x',
            50: 'l',
            100: 'c',
            500: 'd',
            1000: 'm'
        }
        for num, expected in test_cases.items():
            result = int_to_roman_lowercase(num)
            self.assertEqual(result, expected,
                           f"{num} should convert to '{expected}'")

    def test_subtractive_roman_numerals(self):
        """Subtractive notation should work correctly"""
        test_cases = {
            4: 'iv',
            9: 'ix',
            40: 'xl',
            90: 'xc',
            400: 'cd',
            900: 'cm'
        }
        for num, expected in test_cases.items():
            result = int_to_roman_lowercase(num)
            self.assertEqual(result, expected,
                           f"{num} should convert to '{expected}'")

    def test_complex_roman_numerals(self):
        """Complex numbers should convert correctly"""
        test_cases = {
            1984: 'mcmlxxxiv',
            2024: 'mmxxiv',
            444: 'cdxliv',
            1666: 'mdclxvi'
        }
        for num, expected in test_cases.items():
            result = int_to_roman_lowercase(num)
            self.assertEqual(result, expected,
                           f"{num} should convert to '{expected}'")

    def test_zero_special_case(self):
        """Zero should convert to 'n' (nulla)"""
        result = int_to_roman_lowercase(0)
        self.assertEqual(result, 'n')

    def test_roman_numerals_lowercase(self):
        """All Roman numerals should be lowercase"""
        for i in [1, 5, 10, 50, 100, 500, 1000]:
            result = int_to_roman_lowercase(i)
            self.assertEqual(result, result.lower(),
                           f"Roman numeral for {i} should be lowercase")


class TestConfigurationParsing(unittest.TestCase):
    """Test configuration file parsing"""

    def test_config_structure(self):
        """Configuration parsing structure should be correct"""
        # This is a basic test - more comprehensive tests would require
        # creating temporary config files
        from preprocess_htrc import parse_config_file
        # Just verify function exists and is callable
        self.assertTrue(callable(parse_config_file))


class TestPOSTagCoverage(unittest.TestCase):
    """Test POS tag selection comprehensiveness"""

    def test_includes_nouns(self):
        """Should include all noun POS tags"""
        noun_tags = ['NE', 'NN', 'NNP', 'NNPS']
        for tag in noun_tags:
            self.assertIn(tag, POS_TAGS, f"Noun tag '{tag}' should be included")

    def test_includes_verbs(self):
        """Should include all verb POS tags"""
        verb_tags = ['VB', 'VBP', 'VBZ', 'VBD', 'VBN', 'VBG']
        for tag in verb_tags:
            self.assertIn(tag, POS_TAGS, f"Verb tag '{tag}' should be included")

    def test_includes_adjectives(self):
        """Should include all adjective POS tags"""
        adj_tags = ['JJ', 'JJS', 'JJR']
        for tag in adj_tags:
            self.assertIn(tag, POS_TAGS, f"Adjective tag '{tag}' should be included")

    def test_includes_adverbs(self):
        """Should include all adverb POS tags"""
        adv_tags = ['RB', 'RBR', 'RBS']
        for tag in adv_tags:
            self.assertIn(tag, POS_TAGS, f"Adverb tag '{tag}' should be included")


class TestReproducibilityGuarantees(unittest.TestCase):
    """Test that reproducibility guarantees are maintained"""

    def test_parameters_are_constants(self):
        """Key parameters should be constants (uppercase)"""
        # This tests naming convention to ensure parameters are treated as constants
        self.assertTrue('POS_TAGS' in dir(sys.modules['preprocess_htrc']))
        self.assertTrue('MIN_WORD_LENGTH' in dir(sys.modules['preprocess_htrc']))
        self.assertTrue('MIN_WORD_FREQUENCY' in dir(sys.modules['preprocess_htrc']))

    def test_stopword_filters_immutable(self):
        """Stopword filters should all be enabled"""
        for category in STOPWORD_FILTERS:
            self.assertTrue(STOPWORD_FILTERS[category],
                          f"Stopword category '{category}' must be enabled for replication")


def run_tests():
    """Run all tests and return results"""
    # Create test suite
    loader = unittest.TestLoader()
    suite = unittest.TestSuite()

    # Add all test classes
    suite.addTests(loader.loadTestsFromTestCase(TestProcessingParameters))
    suite.addTests(loader.loadTestsFromTestCase(TestCharacterCleaning))
    suite.addTests(loader.loadTestsFromTestCase(TestRomanNumerals))
    suite.addTests(loader.loadTestsFromTestCase(TestConfigurationParsing))
    suite.addTests(loader.loadTestsFromTestCase(TestPOSTagCoverage))
    suite.addTests(loader.loadTestsFromTestCase(TestReproducibilityGuarantees))

    # Run tests
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)

    return result.wasSuccessful()


if __name__ == '__main__':
    success = run_tests()
    sys.exit(0 if success else 1)
