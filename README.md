FPRepo
======

FPRepo is a package repository manager. It takes distribution packages (only
.deb for the moment) and generates repositories trees suitable for HTTP
distribution.

It initially came from a side project, FPMBot, that was using the
[Effing Package Manager](http://github.com/jordansissel/fpm) to build
distribution packages, and fprepo was a component of fpmbot that distributes
generated packages.

Inotify based repository
------------------------

fprepo can simply be used using an inotify based installation backed by systemd
path units. Installation is somple:

- copy `fprepo-deb` to `/usr/bin/fprepo-deb`
- install `fprepo-deb@.path` and `fprepo-deb@.service` systemd units (generally
  in `/etc/systemd/system/`)

Then, you need to create a repository. We suggest to puck a subfolder of
`/var/lib/fprepo`. Taking for example `/var/lib/fprepo/myrepo-deb`:

- `/var/lib/fprepo/myrepo-deb` is the path you should serve over HTTP
- `/var/lib/fprepo/myrepo-deb.gpg` is your GPG keyring for signing packages
  (keyring and secret key is created automatically on first invocation)
- `/var/lib/fprepo/myrepo-deb/pkgs/` is the directory where you need to put you
  packages for the repository metadata to automatically be regenerated.

Then, you need to enable the repository on systemd:

    mkdir -p /var/lib/fprepo/myrepo-deb/pkgs/
    systemctl enable 'fprepo-deb@var-lib-fprepo-myrepo\x2ddeb.service'
    systemctl enable --now 'fprepo-deb@var-lib-fprepo-myrepo\x2ddeb.path'

Then, put packages over the `/var/lib/fprepo/myrepo-deb/pkgs/` directory, and
watch the metatada being generated. Your repository is ready.


Service API
-----------

TODO: make the package format part of the API and not a command line argument.

Manages a package format specific repository. Listen on HTTP protocol and
accepts API requests with methods PUT and POST protected by an API Key that must
be specified on HTTP header `APIKey`.

- `PUT /reponame/releaseid/package.{deb,rpm,...}`: Add a package to a release.
  The release must not have been published.
- `PUT /reponame/releasetag/?from=releaseid`: Release `releaseid` under
  `releasetag`

Typical usage would be for the continuous integration server (fpmbot) to send
all package files using the build timestamp as `releaseid` and then to release
it with `PUT /reponame/latest/?from=<timestamp>`

`fprepo` make use of diverse helpers per format like `fprepo-deb`

The scripts `fprepo-<format>` are scripts that creates a repository in the
current directory from scanned packages.

