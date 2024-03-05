# Encryption and Decryption Program

This program allows encryption and decryption of text in English using various methods:
- Caesar cipher
- Vigenere cipher

## Features

- Encrypt and decrypt text using Caesar, Vigenere.
- Specify encryption or decryption mode.
- Provide encryption key or shift value.
- Input text from terminal or file.
- Output encrypted or decrypted text to terminal or file.

## Usage

```bash
perl cipher.pl --mode MODE --method METHOD --key KEY [--input_file INPUT_FILE] [--output_file OUTPUT_FILE]
```

Test files (caesar_example_shift_1.txt and vigenere_example_key_enigma.txt) are provided for testing the program with encryption option.
Example usage with printing text to stdout:

```bash
perl main.pl --mode decrypt --method caesar --key 1 --input_file caesar_example_shift_1.txt
perl main.pl --mode decrypt --method vigenere --key enigma --input_file vigenere_example_key_enigma.txt
```