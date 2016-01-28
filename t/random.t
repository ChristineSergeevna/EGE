use strict;
use warnings;

use Test::More tests => 19;
use Test::Exception;

use List::Util qw(sum);

use lib '..';
use EGE::Random;

my $v;

$v = rnd->in_range(1, 10);
ok 1 <= $v && $v <= 10, 'in_range';

throws_ok { rnd->in_range(1..10); } qr/arguments/, 'in_range(1..10)';

is rnd->in_range(1, 0), 1, 'in_range empty';
is rnd->in_range_except(1, 2, 1), 2, 'in_range_except';
is rnd->in_range_except(1, 4, [1, 2, 3]), 4, 'in_range_except many';
{
    my @cnt;
    @cnt[rnd->in_range_except(1, 7, [1, 3, 4, 6])]++ for 1 .. 3000;
    is_deeply [ grep $cnt[$_], 0 .. $#cnt ], [2, 5, 7], 'in_range_except historgam 1';
    is scalar(grep $_ && abs($_ - 1000) > 99, @cnt), 0, 'in_range_except historgam 2';
}

$v = rnd->coin;
ok $v == 0 || $v == 1, 'coin';

$v = rnd->pick('a' .. 'z');
ok $v =~ /^[a-z]$/, 'pick';

{
    my @v = rnd->pick_n(2, 'a' .. 'z');
    ok @v == 2 && $v[0] ne $v[1] && join('', @v) =~ /^[a-z]{2}$/, 'pick_n few';
    @v = rnd->pick_n(25, 'a' .. 'z');
    ok @v == 25 && join('', @v) =~ /^[a-z]{25}$/, 'pick_n many';
    @v = rnd->shuffle('a' .. 'z');
    ok @v == 26 && join('', sort @v) =~ join('', 'a' .. 'z'), 'shuffle';
}

subtest pick_except => sub {
    my @r = 'a'..'d';
    for (1..3) {
        my $p = rnd->pick(@r);
        my $v = rnd->pick_except($p, @r);
        ok $v =~ /^[a-d]$/, "in $_";
        isnt $v, $p, "out $_";
    }
};

throws_ok { rnd->pick() } qr/empty/, 'pick from empty';
throws_ok { rnd->pick_n(3, 1, 2) } qr/^pick_n/, 'pick_n too many';
throws_ok { rnd->pick_except(3) } qr/except/, 'except nothing';

{
    my ($v1, $v2, $v3) = rnd->pick_n_sorted(3, 'a' .. 'z');
    ok $v1 lt $v2 && $v2 lt $v3 && "$v1$v2$v3" =~ /^[a-z]{3}$/, 'pick_n_sorted';
}

{
    my @v = rnd->split_number(20, 3);
    ok @v == 3 && 3 == grep($_ > 0, @v) && sum(@v) == 20, 'split_number';
}

{
    my $v = rnd->get_letter_from_string('qw');
    ok $v eq 'q' || $v eq 'w' , 'get_letter_from_string';
}

1;
