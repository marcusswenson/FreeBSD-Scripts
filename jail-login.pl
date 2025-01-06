#!/usr/bin/env perl


################################################################################
# Author: mswenson.dev
# Date: 2025.01.06
#
# This script makes it easier to select a jail to login to as root.
################################################################################


use strict;
use warnings;
use utf8;
use Data::Dumper;


my $cmd_output = `jls`;
my @cmd_output = split("\n", $cmd_output);
shift(@cmd_output);


my @jail_names;
foreach my $line (@cmd_output) {
    $line =~ /^\s+(\d+)\s+(\w+)\s+(\/.+)$/;
    my $jail_id = $1;
    my $jail_name = $2;
    my $jail_path = $3;

    push(@jail_names, $jail_name);
}

print "\n";
print "Select the number of the jail to login to:\n\n";

my $number = 1;
foreach (@jail_names) {
    print "\t${number}. ${_}\n";
    $number++;
}

print "\nSelection: ";
chomp(my $selection = <STDIN>);
$selection =~ s/\s//g; # remove whitespace globally

# now handle our selection - either print an error or drop to a login.
if ($selection =~ /^\d+$/ && $selection > 0 && defined($jail_names[$selection - 1])) {
    my $selected_jail_name = $jail_names[$selection - 1];
    print "\nLogging into '${selected_jail_name}' jail as root...\n\n";
    exec("jexec ${selected_jail_name} login -f root");
} else {
    print "\n'${selection}' is not a valid choice.\n\n";
}
