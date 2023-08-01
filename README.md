pass-pdf
========

A [password-store](https://www.passwordstore.org/) extension to
archive your passwords as a printable PDF.  Main use-cases are to
create fully offline backups and to give your less technical loved
ones access to your online accounts when you die.

Install with `make install` and uninstall with `make uninstall`.  Uses
the GNU groff(7) typesetting system to generate PDFs, if you're on a
GNU Linux distro it's probably already installed.  You'll need to set
several environemnt variables set in order to use this, see pass(1)
for details.

Future Work
---
- PDF generations works with GNU groff, don't hardcode groff and make
  sure it works with BSD and other non-GNU roff/troff implementations.
- **Major Issue** Despite using preconv to convert non-ascii
  characters in the source into hex codes, groff is too lazy to go
  looking for the fonts needed to encode the overwhelming majority of
  Earth's languages.  Idk what else I'd expect from GNU's shitty
  knockoff of a Eunuchs typesetting system birthed as the failed
  abortion of an assembly language mother and an absent but surely
  syphilitic father 😒.
- Figure out how to do zsh completions for this.

License
---
Idk whatever.  Maybe someday I'll have an opinion about licenses, but
if the information is free, then it's free, eh?


