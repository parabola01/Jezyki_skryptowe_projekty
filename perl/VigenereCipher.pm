#Aleksandra Jaroszek grupa 
package VigenereCipher;

use strict;
use warnings;

sub encrypt {
    my ($text, $key) = @_;
    my $encrypted_text = "";
    my $key_length = length($key);
    my $index = 0;

    foreach my $char (split //, $text) {
        if ($char =~ /[a-zA-Z]/) {
            my $base = $char =~ /[a-z]/ ? ord('a') : ord('A');
            my $offset = ord($char) - $base;
            my $key_char = substr($key, $index % $key_length, 1);
            my $key_offset = ord($key_char) - ord('a');
            my $new_offset = ($offset + $key_offset) % 26;
            $encrypted_text .= chr($base + $new_offset);
            $index++;
        } else {
            $encrypted_text .= $char;
        }
    }

    return $encrypted_text;
}

sub decrypt {
    my ($text, $key) = @_;
    my $decrypted_text = "";
    my $key_length = length($key);
    my $index = 0;

    foreach my $char (split //, $text) {
        if ($char =~ /[a-zA-Z]/) {
            my $base = $char =~ /[a-z]/ ? ord('a') : ord('A');
            my $offset = ord($char) - $base;
            my $key_char = substr($key, $index % $key_length, 1);
            my $key_offset = ord($key_char) - ord('a');
            my $new_offset = ($offset - $key_offset) % 26; 
            $new_offset += 26 if $new_offset < 0; 
            $decrypted_text .= chr($base + $new_offset);
            $index++;
        } else {
            $decrypted_text .= $char;
        }
    }

    return $decrypted_text;
}

1;