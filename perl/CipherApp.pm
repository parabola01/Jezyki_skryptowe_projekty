#Aleksandra Jaroszek grupa 
package CipherApp;

use strict;
use warnings;
use CaesarCipher;
use VigenereCipher;
use FindBin qw($RealBin);
use lib $RealBin;
use File::Basename qw(dirname);
use File::Spec;

chdir $RealBin;

sub help {
    print <<HELP;
    Usage: $0 --mode MODE --method METHOD --key KEY [--input_file INPUT_FILE] [--output_file OUTPUT_FILE]

    DESCRIPTION:
     This program allows encryption and decryption of text using various methods:
    - Caesar cipher: A substitution cipher where each letter in the plaintext is shifted a certain number of places down or up the alphabet.
    - Vigenere cipher: A method of encrypting alphabetic text by using a simple form of polyalphabetic substitution. It uses a keyword to shift letters in the plaintext according to a repeating sequence.

    NOTE: This program only supports the English alphabet.

    OPTIONS:
    --mode MODE         Encryption or decryption mode. Valid values: 'encrypt', 'decrypt'.
    --method METHOD     Encryption method. Valid values: 'caesar', 'vigenere'.
    --key KEY           Encryption key. For Caesar and Vigenere cipher, it is a shift value or a keyword. 
            
    --input_file FILE   Path (relative or absolute) to the input file containing text to encrypt or decrypt. (Default: Read from stdin)
    --output_file FILE  Path (relative or absolute)to the output file to save encrypted or decrypted text. If the specified file does not exist, it will be created. (Default: Write to stdout)
    -h, --help          Display this help message and exit.


    DEFAULT BEHAVIOR:
    If no input_file is provided, the program will read from terminal (stdin) by default.
    If no output_file is provided, the program will write to terminal (stdout) by default.

    REQUIREMENTS:
    - Perl 5.10 or later

    EXAMPLES:
    Encrypt text using Caesar cipher:
        perl $0 --mode encrypt --method caesar --key 3

    Decrypt text using Vigenere cipher:
        perl $0 --mode decrypt --method vigenere --key SECRETKEY --input_file encrypted.txt
        
HELP
    exit(0);
}

sub main {
    my ($mode, $method, $key_or_shift, $input_file, $output_file) = @_;

    if ($mode ne "encrypt" && $mode ne "decrypt") {
        print "Invalid mode. Mode must be 'encrypt' or 'decrypt'\n";
        exit 1;
    }

    if ($method ne "caesar" && $method ne "vigenere") {
        print "Invalid method. Method must be 'caesar', 'vigenere'\n";
        exit 1;
    }

    if (!$input_file) {
        print "Enter text: ";
        $input_file = "stdin";
    }

    if (!$output_file) {
        $output_file = "stdout";
    }

    my $text;

    if ($input_file && $input_file ne "stdin") {
        my $absolute_path;
        if (-e $input_file) {
            $absolute_path = $input_file;
        } else {
            my $parent_dir = dirname($RealBin);
            $absolute_path = File::Spec->rel2abs($input_file, $parent_dir);
        }
        if (-e $absolute_path) {
            if (open(my $fh, '<', $absolute_path)) {
                $text = do { local $/; <$fh> };
                close($fh);
            } else {
                print "Could not open file '$absolute_path'\n";
                exit 1;
            }
        } else {
            print "File '$absolute_path' does not exist!\n";
            exit 1;
        }
    } else {
        $text = <STDIN>;
    }

    if ($text =~ /^[A-Za-z\s[:punct:]]+$/) {
    } else {
        print "Text to $mode shouldn't contains non-English alphabet characters and be empty.\n";
        exit 1;
    }

    chomp($text);
    my $result;
    if ($mode eq "encrypt") {
        if ($method eq "caesar") {
            $result = CaesarCipher::encrypt($text, $key_or_shift);
        } elsif ($method eq "vigenere") {
            $result = VigenereCipher::encrypt($text, $key_or_shift);
        }
    } elsif ($mode eq "decrypt") {
        if ($method eq "caesar") {
            $result = CaesarCipher::decrypt($text, $key_or_shift);
        } elsif ($method eq "vigenere") {
            $result = VigenereCipher::decrypt($text, $key_or_shift);
        }
    }

    if ($output_file && $output_file ne "stdout") {
        my $absolute_path;
        if (-d $output_file) { 
            print "Output path '$output_file' is a directory, cannot write output.\n";
            exit 1;
        } elsif (-e $output_file) {
            $absolute_path = $output_file;
        } else {
            my $parent_dir = dirname($RealBin); 
            $absolute_path = File::Spec->rel2abs($output_file, $parent_dir);
        }
        if (open(my $fh, '>', $absolute_path)) {
            print $fh $result;
            close($fh);
        } else {
            print "Invalid file path '$absolute_path'\n";
            print "Result: $result\n";
        }
    } elsif (!$output_file || $output_file eq "stdout") {
        print "Result: $result\n";
    }

}

1;