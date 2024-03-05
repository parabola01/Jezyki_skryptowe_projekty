#!/usr/bin/perl
#Aleksandra Jaroszek grupa 

use strict;
use warnings;
use Getopt::Long;
use FindBin qw($RealBin);
use lib $RealBin;
use CipherApp;

chdir $RealBin;

my ($mode, $method, $key_or_shift, $input_file, $output_file);
GetOptions(
    "mode=s" => \$mode,
    "method=s" => \$method,
    "key=s" => \$key_or_shift,
    "input_file=s" => \$input_file,
    "output_file=s" => \$output_file,
    "h" => sub { CipherApp::help(); exit(0); },
    "help" => sub { CipherApp::help(); exit(0); }
);

if (!$mode && !$method && !$key_or_shift && !$input_file && !$output_file) {
        print "No arguments provided. Use -h or --help for usage information.\n";
        exit 1;
    }

if (!$mode || !$method || !$key_or_shift) {
    print "Missing required arguments. Use -h or --help for usage information.\n";
    exit 1;
}

if ($method eq "caesar") {
        if ($key_or_shift !~ /^\d+$/ || $key_or_shift < 0 || $key_or_shift > 25) {
            print "Invalid key for Caesar cipher. Key must be a positive integer between 0 and 25.\n";
            exit 1;
        }
    } elsif ($method eq "vigenere") {
        if ($key_or_shift =~ /[^a-zA-Z]/) {
            print "Invalid key for Vigenere cipher. Key must contain only letters (without spaces or digits).\n";
            exit 1;
        }
    }

CipherApp::main($mode, $method, $key_or_shift, $input_file, $output_file);
