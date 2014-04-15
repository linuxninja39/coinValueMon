#!/usr/bin/env perl

use strict;
use warnings;

use LWP::UserAgent;
use JSON;
use DBI;

MAIN: {

	my $req = HTTP::Request->new(GET => 'http://www.coinchoose.com/api.php?base=BTC');
	my $ua = new LWP::UserAgent();
	$ua->agent("CoinValueMon/0.1 ");
	my $res = $ua->request($req);

	# Check the outcome of the response
	if (!$res->is_success) {
		print "response failed\n";
		print $res->status_line, "\n";
		exit 1;
	}
		
	my $jsonString = $res->content;

	my $jsonObj = decode_json($jsonString);

	my $dbh = DBI->connect('dbi:mysql:CryptoGods','root','') or die 'could not connect to db: ' . DBI->errstr;

	my $coinSelectStmt = $dbh->prepare("select * from Coin where symbol = ?");
	my $coinUpdateStmt = $dbh->prepare("update Coin set profitability = ? where symbol = ?");
	my $coinInsertStmt = $dbh->prepare("insert into Coin set symbol = ?, name = ?, profitability = ?");
	my $c = 0;
	foreach my $coin (@$jsonObj) {
		my $sym = lc($coin->{symbol});
		$coinSelectStmt->execute($sym);
		if ($coinSelectStmt->rows == 0) {
			$coinInsertStmt->execute(
				$coin->{symbol},
				$coin->{name},
				$coin->{adjustedratio}
			) or print "could not insert coin($sym):" . $coinInsertStmt->errstr;
			print 'inserted ', $coin->{symbol}, ' to ', $coin->{adjustedratio},"\n";
		} else {
			$coinUpdateStmt->execute(
				$coin->{adjustedratio},
				$coin->{symbol}
			) or print "could not update coin($sym):" . $coinUpdateStmt->errstr;
			print 'updated ', $coin->{symbol}, ' to ', $coin->{adjustedratio},"\n";
		}
	}
}
