#!/usr/bin/perl -w

#################################################################################
# XomBot.pl [nick]                                                              #
#                                                                               #
# Your friendly XOmB bot for #xomb                                              #
#################################################################################

package Bot;
use base qw(Bot::BasicBot);
use warnings;
use strict;
use URI::Title qw( title );
use URI::Find::Simple qw( list_uris );
use LWP 5.64;

my($businessChannel) = '#xomb';
my($pleasureChannel) = '##l2l';
my $mynick = shift || 'XOmBot';
my $browser = LWP::UserAgent->new;
my $commitid = "";
my $first = 1;

my $good = 0;
my $bad = 0;

my ($bot) = Bot->new(
		server => "irc.freenode.net",
		port => "8001",
		channels => [ $businessChannel, $pleasureChannel , "##IwantAkitty", "#rstatus"],
		nick => $mynick,
		charset => 'utf-8',
		);

$bot->run();

sub connected {
		my $self = shift;
		$self->say(channel => $_, body => "$mynick is online. !commands will show what I can do.") for (@{$self->{channels}});
}

sub tick {
		#check_rss();
		return 60;
}

sub said {
		my $self = shift;
		my $message = shift;
		my $body = $message->{body};
		my $nick = $message->{who};
		my $channel = $message->{channel};
		my $address = $message->{address};

		# --- url announce ---
		if(my @urls = list_uris($body)){
				if($nick ne "github-xombot"){
						$self->reply($message, title($_)) for (@urls);
				}
		}

		# --- command list ---
		if($body =~ m/^\!commands/ || $body =~ m/^\!h.lp/i){
				# show all the commands that xombot listens to
				$self->say(channel => $channel, body => "!wiki [search term] - will search the wiki for the given word or phrase.");
				$self->say(channel => $channel, body => "!latest - will show the last commit to the offical XOmB repository.");
				$self->say(channel => $channel, body => "!google [phrase] for [nick] - answer questions. More bangs to shoot from the hip.");
				$self->say(channel => $channel, body => "!coinflip - ...");
				$self->say(channel => $channel, body => "!santa - ask Santa whether $mynick has been naughty or nice.");
		}

		if ($body =~ m/^\!wiki\s*([\w*\s]*)/){
				# check if article exists in the wiki
				get_wiki_entry($1, $channel);
		}
		
		if($body =~ m/^\!latest/){
				# show the latest commit the next loop around
				$commitid = "";
		}

		if($body =~ m/^\!(!*)google(!*) (.*) for (.*)/){
				my($term) = $3;
				my($target) = $4;
				my($lucky);

				if($1 ne "" || $2 ne ""){
						$lucky = "&l=1";
				}

				$term =~ s/ /+/g;
						
				$self->say(channel => $channel, who => $target, address => "1", body => "http://lmgtfy.com/?q=$term$lucky");
		}

		if($body =~ m/^\!coinflip/){
				my $outcome;

				if($body =~ m/^\!coinflip.* heads (.*) tails (.*)/){
						$outcome = $1;
						$outcome = $2 if int(rand(2)) == 1;
				}else{
						$outcome = "heads";
						$outcome = "tails" if int(rand(2)) == 1;
				}

				#$self->say(channel => $channel, who => $nick, address => "1", body => "$outcome");
				$self->say(channel => $channel, body => "$outcome");
		}

		if($body =~ m/^\!santa/){
				if($good >= $bad){
						$self->emote(channel => $channel, body => "has been a good little robotic zombie");
				}else{
						$self->emote(channel => $channel, body => "is getting coal in its metal stocking");
				}
		}

		# --- miscellaneous behaviors ---

		# annoy duck
		if($body eq "hi" and $nick eq "duckinator"){
				$self->say(channel => $channel, who => $nick, body => "hi", address => "1");
		}

		my($respondedFlag) = 0;

		if ($address || $body =~ m/$mynick/){
				my $compliment = $body;

				if($compliment =~ m/good/i || $compliment =~ m/cookie/i || $compliment =~ m/<3/){
						$self->emote(channel => $channel, body => "drools");

						$good++;
						$respondedFlag = 1;
				}elsif($compliment =~ m/bad/i || $compliment =~ m/spank/i){
						$self->emote(channel => $channel, body => "cowers");

						$bad++;
						$respondedFlag = 1;
				}
		}

		if($address && !$respondedFlag){
				$self->say(channel => $channel, who => $nick, address => "1", body => "brains...");
		}

		return undef;
}

sub check_rss {
		my $response = $browser->get("http://github.com/feeds/xomboverlord/commits/xomb/unborn");

		if($response->is_success && $response->content =~ m/<entry>\s*<id>.*\/(\w*)<\/id>/){
				my $commiter = "Unknown";
				my $commit_msg = "Unspecified";
				my $orig_commitid = $commitid;			
			
				#if it's not the last one we announced
				if($commitid ne $1){
						$commitid = $1;
				
						# get try to get the info to announce it
						if($response->content =~ m/<entry>.*?<title>(.*?)<\/title>/s){
								$commit_msg = $1;
						}

						# get try to get the author to announce it
						if($response->content =~ m/<name>(\w*)<\/name>/){
								$commiter = $1;
						}				
				
						if($commit_msg ne "Sorry, this commit log is taking too long to generate."){
								unless($first){
										$bot->say(channel => $businessChannel, body => "Commit made by $commiter: $commit_msg");
										$bot->say(channel => $businessChannel, body => "View: http://github.com/xomboverlord/xomb/commit/$commitid");
								}else{
										$first = 0;
								}
						}else{
								# we don't know if there actually was a new commit
								$commitid = $orig_commitid;
						}
				}
		}
}



sub get_wiki_entry {
	my $articlename = shift;
	my $channel = shift;

	#replace spaces with +
	$articlename =~ s/\s/\+/gs;

	# searching for the article rather than going directly to it allows us to ignore the issue of case sensitivity
	my $response = $browser->get("http://wiki.xomb.org/index.php?search=$articlename&go=Go");

	#check if article exists
	my $exists = 1;
	if($response->content =~ m/There is no page titled/)
	{
		$exists = 0;
	}

	my $content = $response->content;

	# remove the html tags
	# the following line breaks syntax highlighting in intype :( 
	$content =~ s/<(?:[^>'"]*|(['"]).*?\1)*>//gs;

	#replace + with spaces
	$articlename =~ s/\+/ /gs;

	if ($response->is_success && $exists)
	{
		# try to get a definition
		if( $content =~ m/(.*?$articlename.*?\.)/i)
		{
			$bot->say(channel => $channel, body => $1);
		}

		#replace spaces with _
		$articlename =~ s/\s/_/gs;

		$bot->say(channel => $channel, body => "Full article here: " . $response->base);
	}
	else
	{
		$bot->say(channel => $channel, body => "Sorry, there's no article by that name");
		# try to search for similar articles
		search_for_article($articlename, $channel);
	}

}

sub search_for_article {
	my $searchterm = shift;
	my $channel = shift;

	# replace spaces with +
	$searchterm =~ s/\s/\+/gs;
	
	my $response = $browser->get("http://wiki.xomb.org/index.php?search=$searchterm&go=Go");
	
	if($response->is_success)
	{
		if($response->content =~ m/<li><a href="\/index\.php\?title=(\w*)/)
		{
			$bot->say(channel => $channel, body => "Did you mean $1: http://wiki.xomb.org/index.php?title=$1");	
		}
	}

}
