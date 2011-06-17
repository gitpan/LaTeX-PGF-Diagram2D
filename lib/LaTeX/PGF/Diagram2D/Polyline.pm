
package LaTeX::PGF::Diagram2D::Polyline;

use 5.000000;
use strict;
use warnings;

use Carp;

our @ISA = qw();

our $VERSION = '1.00';


# Arguments:
# - diagram
# - polyline points

sub new
{
  my $self = undef;

  if($#_ < 4) {
    croak "Usage: LaTeX::PGF::Diagram2D::Polyline->new(diagram, xaxis, yaxis, pointsarrayref)";
  } else {
    my $class = shift;
    my $diagram = shift;
    my $ax = shift;
    my $ay = shift;
    my $points = shift;
    $self = {
      'p'	=>	$points,	# Point coordinates
      'c'	=>	'black',	# Color
      's'	=>	0,		# Line style
      'w'	=>	0.5,		# Linewidth factor
      'd'	=>	$diagram,	# Parent diagram
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



sub set_width
{
  my $self = undef;
  if($#_ < 0) {
    croak "Usage: \$polyline->set_width(widthfactor)";
  } else {
    $self = shift; $self->{'w'} = shift;
  }
  return $self;
}



sub plot
{
  my $self = shift;
  my $d = $self->{'d'};
  my $fh = $d->{'f1'};
  my $ax = $self->{'ax'}; my $ay = $self->{'ay'};
  my @p;
  my $ar = $self->{'p'};
  my $i = 0;
  for($i = 0; $i <= $#$ar; $i++) {
    $p[$i] = $d->value_to_coord($ax, $ay, $ar->[$i], $i);
  }
  $d->set_color($self->{'c'});
  $d->setlinewidth_mm( 0.2 * $self->{'w'} );
  $i = 0;
  while($i < $#p) {
    if($i) {
      print $fh "\\pgfpathlineto{";
      $d->write_point($p[$i], $p[$i+1]);
      print $fh "}\n";
    } else {
      print $fh "\\pgfpathmoveto{";
      $d->write_point($p[$i], $p[$i+1]);
      print $fh "}\n";
    }
    $i++; $i++;
  }
  print $fh "\\pgfusepath{stroke}\n";
  return $self;
}




1;
__END__

