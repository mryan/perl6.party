#!/usr/bin/env perl

use lib qw<lib>;
use Mojolicious::Lite;
use Mojo::UserAgent;
use Mojo::Util qw/trim/;
use Perl5::Party::Posts;

use constant GLOT_KEY => '02fb41ba-78cd-44d8-9f30-2a28350000a8';
my $posts = Perl5::Party::Posts->new;
my $ua = Mojo::UserAgent->new;

app->config( { hypnotoad => { listen => ['http://*:3000'], proxy => 1 }} );

get '/about';

get '/' => sub {
    my $c = shift;
    $c->stash( posts => $posts->all );
} => 'index';

get '/post/:post' => sub {
    my $c = shift;
    my ($meta, $post) = $posts->load( $c->param('post') );
    $post or return $c->reply->not_found;
    $c->stash( %$meta, post => $post );
} => 'post';

post '/run' => sub {
    my $c = shift;
    my $code = $c->param('code')
        or return $c->reply->not_found;
    $code =~ s/\N{ZERO WIDTH SPACE}//g;

    $ua->post(
        'https://run.glot.io/languages/perl6/latest' => {
            'Content-type'  => 'application/json',
            'Authorization' => 'Token ' . GLOT_KEY,
        } => json => { files => [{ name => 'main.p6', content => $code }] }
        => sub {
            my ($ua, $tx) = @_;
            my $out = $tx->res->json;
            $out = trim join "\n", $out->{stdout} // (),
                $out->{stderr} ? "STDERR:\n$out->{stderr}" : ();
            $c->render( text => $out );
        },
    );

    $c->render_later;
};

app->start;
