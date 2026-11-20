#!/usr/bin/env perl
# logs/*.log 내용을 README.md 의 <!-- LOG:이름 --> ... <!-- /LOG:이름 --> 사이에 코드블록으로 채워 넣는다.
# (perl 은 macOS/Linux/Git Bash 모두 기본 포함)
use strict;
use warnings;
use File::Basename qw(dirname);
use Cwd qw(abs_path);

my $root = dirname(dirname(abs_path($0)));
my $readme = "$root/README.md";

sub slurp { my $f = shift; open my $fh, '<:raw', $f or die "$f: $!"; local $/; my $c = <$fh>; close $fh; return $c; }

my $text = slurp($readme);
my $n = 0;
$text =~ s{(<!-- LOG:(\w+) -->).*?(<!-- /LOG:\2 -->)}{
  $n++;
  my ($open, $name, $close) = ($1, $2, $3);
  my $log = "$root/logs/$name.log";
  my $body;
  if (-e $log) {
    (my $c = slurp($log)) =~ s/\s+\z//;
    $c =~ s/\r\n/\n/g;
    $body = "\n```bash\n$c\n```\n\n전체 로그: [logs/$name.log](logs/$name.log)\n";
  } else {
    $body = "\n> 아직 로그가 없습니다. `bash scripts/$name.sh` 를 실행하세요.\n";
  }
  "$open$body$close";
}gse;

open my $out, '>:raw', $readme or die $!;
print $out $text;
close $out;
print "README.md 갱신 완료: $n개 로그 블록\n";
