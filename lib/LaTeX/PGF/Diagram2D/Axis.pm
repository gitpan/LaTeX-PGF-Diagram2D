
package LaTeX::PGF::Diagram2D::Axis;

use 5.000000;
use strict;
use warnings;

use Carp;

our @ISA = qw();

our $VERSION = '1.00';

sub new
{
  my $self = undef;
  if($#_ < 0) {
    croak "Usage: LaTeX::PGF::Diagram2D::Axis->new(width,height)";
  } else {
    my $class = shift;
    $self = {
      'min' => 0.0,	# Minimum value
      'max' => 0.0,	# Maximum value
      't' => 0,		# Type: 0=linear, 1=logarithmic
      'ts' => -1.0,	# Tic step
      'gs' => -1.0,	# Grid step
      'bo' => -1.0,	# Border
      'to' => -1.0,	# Tic offset
      'lo' => -1.0,	# Label offset
      'l' => undef,	# Label text
      'u' => undef,	# Unit text
      'dg' => undef,	# Diagram
      'used' => 0,	# Flag: used
      'n' => '',	# Name
      'color' => undef,	# Color
      'omit' => 0,	# Number of scale tics to omit for unit
    };
    bless($self, $class);
  }
  return $self;
}



sub set_grid_step
{
  my $self = undef;
  if($#_ < 1) {
    croak "Usage: \$axis->set_grid_step(value)";
  } else {
    $self = shift; $self->{'gs'} = shift;
  }
  return $self;
}



sub set_tic_step
{
  my $self = undef;
  if($#_ < 1) {
    croak "Usage: \$axis->set_tic_step(value)";
  } else {
    $self = shift; $self->{'ts'} = shift;
  }
  return $self;
}



sub set_linear
{
  my $self = undef;
  if($#_ < 2) {
    croak "Usage: \$axis->set_linear(min,max)";
  } else {
    $self = shift;
    $self->{'min'} = shift;
    $self->{'max'} = shift;
    $self->{'t'} = 0;
    if($self->{'max'} <= $self->{'min'}) {
      carp "Warning: Scale maximum should be larger than minimum!";
    }
  }
  return $self;
}


sub set_logarithmic
{
  my $self = undef;
  if($#_ < 2) {
    croak "Usage: \$axis->set_linear(min,max)";
  } else {
    $self = shift;
    $self->{'min'} = shift;
    $self->{'max'} = shift;
    $self->{'t'} = 1;
    if($self->{'min'} <= 0.0) {
      croak "ERROR: Only positive values allowed for logarithmic scales!";
    }
    if($self->{'max'} <= 0.0) {
      croak "ERROR: Only positive values allowed for logarithmic scales!";
    }
    if($self->{'max'} <= $self->{'min'}) {
      carp "Warning: Scale maximum should be larger than minimum!";
    }
  }
  return $self;
}


sub set_omit
{
  my $self = undef;
  if($#_ < 1) {
    croak "Usage \$axis->set_omit(number)";
  } else {
    $self = shift; $self->{'omit'} = shift;
  }
  return $self;
}



sub correct_if_necessary
{
  my $self = undef;
  my $debug = 0;
  if($#_ < 2) {
    croak "Usage: \$axis->correct_if_necessary(diagram,xyflag)";
  } else {
    $self = shift; my $dg = shift; my $xyflag = shift;
    if($#_ >= 0) { $debug = shift; }
    if($self->{'used'}) {
      if($self->{'to'} < 0.0) {
        if($dg->{'units'} == 1) {
	  $self->{'to'} = 0.2 / 2.54;
	} else {
	  if($dg->{'units'} == 2) {
	    $self->{'to'} = 0.2 * 72.0 / 2.54
	  } else {
	    $self->{'to'} = 0.2;
	  }
	}
      }
      if($self->{'lo'} < 0.0) {
        if($dg->{'units'} == 1) {
	  $self->{'lo'} = $self->{'to'} + 2.0 * $self->{'fs'} / 72.27;
	} else {
	  if($dg->{'units'} == 2) {
	    $self->{'lo'} = $self->{'to'}
	                    + 2.0 * 72.0 * $self->{'dg'}->{'fs'} / 72.27;
	  } else {
	    $self->{'lo'} = $self->{'to'}
	                    + 2.0 * 2.54 * $self->{'dg'}->{'fs'} / 72.27;
	  }
	}
      }
      if($self->{'bo'} < 0.0) {
        if($dg->{'units'} == 1) {
	  $self->{'bo'} = $self->{'to'} + 3.0 * $self->{'fs'} / 72.27;
	} else {
	  if($dg->{'units'} == 2) {
	    $self->{'bo'} = $self->{'to'}
	                    + 3.0 * 72.0 * $self->{'dg'}->{'fs'} / 72.27;
	  } else {
	    $self->{'bo'} = $self->{'to'}
	                    + 3.0 * 2.54 * $self->{'dg'}->{'fs'} / 72.27;
	  }
	}
      }
    } else {
      if($self->{'bo'} < 0.0) {
        if($dg->{'units'} == 1) {
	  $self->{'bo'} = 0.5 / 2.54;
	} else {
	  if($dg->{'units'} == 2) {
	    $self->{'bo'} = 0.5 * 72.0 / 2.54;
	  } else {
	    $self->{'bo'} = 0.5;
	  }
	}
      }
    }
  }
  if($debug) {
    print "DEBUG Axis->correct_if_necessary: " . $self->{'n'} . "\n";
    print "DEBUG bo = " . $self->{'bo'} . "\n";
    print "DEBUG to = " . $self->{'to'} . "\n";
    print "DEBUG lo = " . $self->{'lo'} . "\n";
  }
  return $self;
}



sub value_to_coord
{
  my $back = undef;
  if($#_ < 1) {
    croak "Usage: \$axis->value_to_coord(value)";
  } else {
    my $self = shift;
    my $value = shift;
    my $xmin; my $xmax;
    my $vmin = $self->{'min'}; my $vmax = $self->{'max'};
    if(($self->{'n'} eq 'l') || ($self->{'n'} eq 'r')) {
      $xmin = $self->{'dg'}->{'y3bp'};
      $xmax = $self->{'dg'}->{'y4bp'};
    } else {
      $xmin = $self->{'dg'}->{'x3bp'};
      $xmax = $self->{'dg'}->{'x4bp'};
    }
    if($self->{'t'}) {
      $back = $xmin
              + ((($xmax - $xmin) * (log($value/$vmin))) / (log($vmax/$vmin)));
    } else {
      $back = $xmin + ((($xmax - $xmin) * ($value - $vmin)) / ($vmax - $vmin));
    }
    $back = $self->{'dg'}->rd($back, 5);
  }
  return $back;
}


# dx/dX or dy/dY

sub value_to_derivative
{
  my $back = undef;
  if($#_ < 1) {
    croak "Usage: \$axis->value_to_derivative(value)";
  } else {
    my $self = shift;
    my $value = shift;
    my $xmin; my $xmax;
    my $vmin = $self->{'min'}; my $vmax = $self->{'max'};
    if(($self->{'n'} eq 'l') || ($self->{'n'} eq 'r')) {
      $xmin = $self->{'dg'}->{'y3bp'};
      $xmax = $self->{'dg'}->{'y4bp'};
    } else {
      $xmin = $self->{'dg'}->{'x3bp'};
      $xmax = $self->{'dg'}->{'x4bp'};
    }
    if($self->{'t'}) {			# logarithmic
      $back = ($xmax - $xmin) / ($value * log($vmax/$vmin));
    } else {				# linear
      $back = (($xmax - $xmin) / ($vmax - $vmin));
    }
    $back = $self->{'dg'}->rd($back, 5);
  }
  return $back;
}



sub coord_to_value
{
  my $back = undef;
  if($#_ < 1) {
    croak "Usage: \$axis->coord_to_value(coord)";
  } else {
    my $self = shift; my $coord = shift;
    my $xmin; my $xmax;
    my $vmin = $self->{'min'}; my $vmax = $self->{'max'};
    if(($self->{'n'} eq 'l') || ($self->{'n'} eq 'r')) {
      $xmin = $self->{'y3bp'}; $xmax = $self->{'y4bp'};
    } else {
      $xmin = $self->{'x3bp'}; $xmax = $self->{'x4bp'};
    }
    if($self->{'t'}) {
      $back = $vmin * exp(
        (log($vmax/$vmin) * ($coord - $xmin)) / ($xmax - $xmin)
      );
    } else {
      $back = $vmin + ((($vmax - $vmin) * ($coord - $xmin)) / ($xmax - $xmin));
    }
  }
  return $back;
}



sub set_unit
{
  my $self = undef;
  if($#_ < 1) {
    croak "Usage: \$axis->set_unit(text)";
  } else {
    $self = shift; $self->{'u'} = shift;
  }
  return $self;
}



sub set_label
{
  my $self = undef;
  if($#_ < 1) {
    croak "Usage: \$axis->set_label(text)";
  } else {
    $self = shift; $self->{'l'} = shift;
  }
  return $self;
}



sub set_tic_offset
{
  my $self = undef;
  if($#_ < 1) {
    croak "Usage: \$axis->set_tic_offset(offset)";
  } else {
    $self = shift; $self->{'to'} = shift;
  }
  return $self;
}



sub set_label_offset
{
  my $self = undef;
  if($#_ < 1) {
    croak "Usage: \$axis->set_tic_offset(offset)";
  } else {
    $self = shift; $self->{'lo'} = shift;
  }
  return $self;
}



sub set_border
{
  my $self = undef;
  if($#_ < 1) {
    croak "Usage: \$axis->set_tic_offset(offset)";
  } else {
    $self = shift; $self->{'bo'} = shift;
  }
  return $self;
}



sub set_color
{
  my $self = undef;
  if($#_ < 1) {
    croak "Usage: \$plot->set_color(color)";
  } else {
    $self = shift; $self->{'color'} = shift;
  }
  return $self;
}



1;
__END__

