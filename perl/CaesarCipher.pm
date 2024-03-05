#Aleksandra Jaroszek grupa 2
package CaesarCipher;

use strict;
use warnings;

sub encrypt {
    my ($text, $shift) = @_;
    my $encrypted_text = "";

    foreach my $char (split //, $text) {
        if ($char =~ /[a-zA-Z]/) {
            my $base = $char =~ /[a-z]/ ? ord('a') : ord('A');
            my $offset = ord($char) - $base;
            my $new_offset = ($offset + $shift) % 26;
            $encrypted_text .= chr($base + $new_offset);
        } else {
            $encrypted_text .= $char;
        }
    }

    return $encrypted_text;
}

sub decrypt {
    my ($text, $shift) = @_;
    $shift = 26 - $shift; 
    return encrypt($text, $shift);
}

1;