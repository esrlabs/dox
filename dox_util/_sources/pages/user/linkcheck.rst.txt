linkcheck
=========

This extension overwrites the standard behaviour of the built-in linkcheck of Sphinx.

Sphinx documentations can include links to services which require a login. If not logged in, the
HTML error code is 403.

*linkcheck* ignores 403 instead of treating this as an error, which means everyone can build the
documentation even without having access to these services or when the systems are down.
The small acceptable drawback is that when not logged in, the links are not validated.
