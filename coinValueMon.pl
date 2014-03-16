#!/usr/bin/env perl

use strict;
use warnings;

use LWP::UserAgent;
use JSON;

MAIN: {

	my $req = HTTP::Request->new(GET => 'http://www.coinchoose.com/api.php?base=BTC');
	my $ua = new LWP::UserAgent();
	$ua->agent("MyApp/0.1 ");
	my $res = $ua->request($req);

	# Check the outcome of the response
	if (!$res->is_success) {
		print "response failed\n";
		print $res->status_line, "\n";
		exit 1;
	}
		
	my $jsonString = $res->content;

	my $jsonObj = decode_json($jsonString);

	print "first obj...", $jsonObj->[0]->{0}, "\n";

	my @sortedCoins = sort {$b->{ratio} <=> $a->{ratio}} @$jsonObj;

	my $c = 0;
	print "first 5 coins\n";
	foreach my $coin (@sortedCoins) {
		$c++;
		print $coin->{symbol}, ' ratio ', $coin->{ratio},"\n";
		last if $c > 5;
	}
}
