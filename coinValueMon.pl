#!/usr/bin/env perl

use strict;
use warnings;

use LWP::UserAgent;
use JSON;

my @minedCoins = (
	'ltc',
	'nvc',
	'elc',
	'ftc',
	'pxc',
	'wdc'
);

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

	# this gives coins ordered highest to lowest.
	my @sortedCoins = sort {$b->{ratio} <=> $a->{ratio}} @$jsonObj;

	open FH, ">/tmp/topCoin";

	my $c = 0;
	print "top coin\n";
	foreach my $coin (@sortedCoins) {
		my $sym = lc($coin->{symbol});
		if (scalar grep(/^$sym$/, @minedCoins)) {
			print $coin->{symbol}, ' ratio ', $coin->{ratio},"\n";
			print FH $sym;
			last;
		}
	}
	close FH;
}
