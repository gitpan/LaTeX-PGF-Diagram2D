
package LaTeX::PGF::Diagram2D::Label;

use 5.000000;
use strict;
use warnings;

use Carp;

our @ISA = qw();

our $VERSION = '1.00';


# Arguments:
# - diagram
# - x
# - y
# - text
# - (position)

sub new
{
  my $self = undef;

  if($#_ < 6) {
    croak "Usage: LaTeX::PGF::Diagram2D::Label->new(diagram, xaxis, yaxis, x, y, text[, pos])";
  } else {
    my $class = shift;
    my $diagram = shift;
    my $ax = shift;
    my $ay = shift;
    my $x = shift;
    my $y = shift;
    my $t = shift;
    my $p = undef;
    if($#_ >= 0) {
      $p = shift;
    }
    $self = {
      'x'	=>	$x,		# X position
      'y'	=>	$y,		# Y position
      't'	=>	$t,		# Text
      'p'	=>	$p,		# Alignment
      'd'	=>	$diagram,	# Diagram
      'c'	=>	'black',	# Color
      'ax'	=>	$ax,		# X axis
      'ay'	=>	$ay,		# Y axis
    };
    bless($self, $class);
  }
  return $self;
}



sub set_color
{
  my $self = undef;
  if($#_ < 0) {
    croak "Usage: \$polyline->set_color(color)";
  } else {
    $self = shift; $self->{'c'} = shift;
  }
  return $self;
}



sub plot
{
  my $self = shift;
  my $d = $self->{'d'};
  my $x = $d->value_to_coord(
    $self->{'ax'}, $self->{'ay'}, $self->{'x'}, 0
  );
  my $y = $d->value_to_coord(
    $self->{'ax'}, $self->{'ay'}, $self->{'y'}, 1
  );
  my $fh = $d->{'f1'};
  $d->set_color($self->{'c'});
  print $fh "\\pgftext[at={";
  $d->write_point($x, $y);
  print $fh "}";
  if(defined($self->{'p'})) {
    print $fh "," . $self->{'p'};
  }
  print $fh "]{";
  print $fh "" . $self->{'t'};
  print $fh "}";
  return $self;
}



1;
__END__

