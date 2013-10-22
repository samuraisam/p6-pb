# Protocol-Buffers

## Overview

This is the Perl 6 Protocol-Buffers project, a port of Google's standard
binary message format and interface definition language to Perl 6.  It is
still in the early stages of implementation.  For example, while the current
code can successfully parse the message definition (`.proto`) files into
ASTs, it still lacks the ability to encode and decode the protocol buffers
themselves.  For more details, see [`docs/ROADMAP`](docs/ROADMAP).


## Prerequisites

Protocol-Buffers requires nothing more than core Perl 6, and is tested with
current Rakudo on at least the JVM and Parrot backends.


## Installation

To manage expectations, we have *not* added Protocol-Buffers to the Perl 6
module ecosystem yet; thus you cannot simply `panda install Protocol-Buffers`
in a single step.  However you can use Panda to install from a git clone,
as follows:

    $ git clone https://github.com/samuraisam/p6-pb.git
    $ panda install p6-pb


## Getting Help

For help with Protocol-Buffers, please come to the `#perl6` IRC channel on
`irc.freenode.net` and ask for `ssutch` or `japhb`.  If we're not available
right away, stick around and we'll get back to you in a bit.


## Reporting Bugs

Bugs and feature requests can be filed in the project's
[GitHub issues queue](https://github.com/samuraisam/p6-pb/issues).


## Contributing

Thank you for contributing!  Please send GitHub pull requests, and we'll
take a look as soon as we can.  Regular contributors are welcome to request
commit bits from us on `#perl6` (see Getting Help above).
