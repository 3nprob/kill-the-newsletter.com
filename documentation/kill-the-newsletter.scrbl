#lang scribble/manual

@title{Kill the Newsletter!}
@author{@author+email["Leandro Facchinetti" "me@leafac.com"]}

@emph{Convert email newsletters into Atom feeds.}

@hyperlink["https://www.kill-the-newsletter.com/"]{https://www.kill-the-newsletter.com/}

@tabular[#:style 'boxed
         #:sep @hspace[1]
         #:row-properties '(bottom-border)
         `((, @bold{Version} , @seclink["changelog/0.0.2"]{0.0.2})
           (, @bold{Documentation} , @hyperlink["https://www.leafac.com/software/kill-the-newsletter"]{https://www.leafac.com/software/kill-the-newsletter})
           (, @bold{License} , @hyperlink["https://gnu.org/licenses/gpl-3.0.txt"]{GNU General Public License Version 3})
           (, @bold{Code of Conduct} , @hyperlink["http://contributor-covenant.org/version/1/4/"]{Contributor Covenant v1.4.0})
           (, @bold{Source} , @hyperlink["https://git.leafac.com/kill-the-newsletter"]{https://git.leafac.com/kill-the-newsletter})
           (, @bold{Bug Reports} , @para{Write emails to @hyperlink["mailto:kill-the-newsletter@leafac.com"]|{kill-the-newsletter@leafac.com}|.})
           (, @bold{Contributions} , @para{Send @hyperlink["https://git-scm.com/docs/git-format-patch"]{patches} and @hyperlink["https://git-scm.com/docs/git-request-pull"]{pull requests} via email to @hyperlink["mailto:kill-the-newsletter@leafac.com"]|{kill-the-newsletter@leafac.com}|.}))]

@section[#:tag "overview"]{Overview}

@emph{Kill the Newsletter!} is an application that converts email newsletters into Atom feeds. It spins up a web server and an email server. The web server is the front-end that allows for the creation of new Atom feeds. The email server receives emails and saves them as Atom entries. The feeds are stored as files in the file system.

@section[#:tag "dependencies"]{Dependencies}

@emph{Kill the Newsletter!} is written in @hyperlink["https://golang.org/"]{Go}. Use @hyperlink["https://glide.sh/"]{Glide} to install the package dependencies:


@nested[#:style 'code-inset @verbatim{
  $ glide install
}]

@section[#:tag "development"]{Development}

Run a local instance of @emph{Kill the Newsletter!} with:

@nested[#:style 'code-inset @verbatim{
  $ go run kill-the-newsletter.go
}]

Visit @hyperlink["http://localhost:8080"]{http://localhost:8080}. Create feeds and send emails to test them. The following command line sends a test email using @hyperlink["http://msmtp.sourceforge.net/"]{msmtp}:

@nested[#:style 'code-inset @verbatim|{
  $ printf 'Subject: Test\n\nHello world of Kill the Newsletters!' | \
    msmtp --host=localhost --port=2525 --from=publisher@example.com -- \
          <feed-token>@localhost
}|]

@section[#:tag "deployment"]{Deployment}

@margin-note{
Because it depends on the file system, it is not possible to deploy @bold{Kill the Newsletter!} to @hyperlink["https://www.heroku.com/"]{Heroku}.

While the build step requires a Go compiler, the environment that runs the application does not need one.

@bold{Do not enable listing the contents of the feeds directory!} The file names contain tokens which are sensitive information.
}

To deploy a self-hosted instance, the recommended environment is a @hyperlink["https://www.docker.com/"]{Docker} container. See the accompanying @tt{Makefile}, @tt{Dockerfile} and @tt{docker-compose.yml}.

@seclink["configuration"]{Configure the application} and setup a web server in front of it. This acts as reverse proxy and serves the contents of the feeds folder as static files. The following is an example configuration for @hyperlink["http://nginx.org/"]{nginx}:

@nested[#:style 'code-inset
        @filebox["/etc/nginx/nginx.conf"
                 @verbatim|{
# …

server {
  listen 443 ssl;
  server_name www.kill-the-newsletter.com;

  location / {
    proxy_pass http://kill-the-newsletter:80;
  }

  location /feeds {
    root /var/www/www.kill-the-newsletter.com;
  }
}

server {
  listen 80;
  server_name www.kill-the-newsletter.com;

  return 301 https://www.kill-the-newsletter.com$request_uri;
}

server {
  listen 80;
  listen 443 ssl;
  server_name kill-the-newsletter.com;

  return 301 https://www.kill-the-newsletter.com$request_uri;
}

# …
                          }|]]

@section[#:tag "configuration"]{Configuration}

@margin-note{See the @hyperlink["https://git.leafac.com/leafac.com/"]{full configuration} for the main @bold{Kill the Newsletter!} deployed instance. It is more complex, including a reverse proxy in front of the email server.}

Configure @emph{Kill the Newsletter!} with a file named @filepath{./kill-the-newsletter.json} in JSON format. The following configuration keys are available:

@tabular[#:style 'boxed
         #:sep @hspace[1]
         #:row-properties '(bottom-border)
         `((, @bold{Key} , @bold{Default} , @bold{Description})
           ("Name" , @tt{Kill the Newsletter!} "The service name, shown in communications to the user.")
           ("Administrator" , @tt|{mailto:administrator@example.com}| "The system administrator contact reference.")
           ("Web.Server" , @tt|{:8080}| "The network address on which the web server listens.")
           ("Web.URL" , @tt|{http://localhost:8080}| "The URL for the application. Used as base for links. Note the lack of a trailing slash.")
           ("Web.URIs.Root" , @tt|{/}| "The root URI for the application. Note the trailing slash.")
           ("Web.URIs.Feeds" , @tt|{/feeds/}| "The URI under which to find the feeds. Note the trailing slash.")
           ("Email.Server" , @tt|{:2525}| "The network address on which the email server listens.")
           ("Email.Host" , @tt|{localhost}| "The host for which the application accepts emails.")
           ("Feed.Path" , @tt|{./feeds/}| "The file system path in which to store the feeds as files.")
           ("Feed.Suffix" , @tt|{.xml}| "The suffix to use for feeds files.")
           ("Feed.URN" , @tt|{localhost}| "The URN to use when creating identifiers for feeds and entries.")
           ("Feed.SizeLimit" , @tt|{1900000}| "The maximum size (in bytes) for a feed. Larger feeds are truncated.")
           ("Token.Length" , @tt|{20}| "The length of the tokens that identify feeds.")
           ("Token.Characters" , @tt|{abcdefghijklmnopqrstuvwxyz0123456789}| "The characters that form tokens."))]

Example:

@nested[#:style 'code-inset
        @filebox["./kill-the-newsletter.json"
                 @verbatim|{
{
  "administrator": "mailto:kill-the-newsletter@leafac.com",
  "web": {
    "server": ":80",
    "url": "https://www.kill-the-newsletter.com"
  },
  "email": {
    "server": ":25",
    "host": "kill-the-newsletter.com"
  },
  "feed": {
    "urn": "kill-the-newsletter"
  }
}
                          }|]]

@section[#:tag "changelog"]{Changelog}

This section documents all notable changes to Kill the Newsletter! It follows recommendations from @hyperlink["http://keepachangelog.com/"]{Keep a CHANGELOG} and uses @hyperlink["http://semver.org/"]{Semantic Versioning}. Each released version is a Git tag.

@;{
 @subsection[#:tag "changelog/unreleased"]{Unreleased} @; 0.0.1 · 2016-02-23

 @subsubsection[#:tag "changelog/unreleased/added"]{Added}

 @subsubsection[#:tag "changelog/unreleased/changed"]{Changed}

 @subsubsection[#:tag "changelog/unreleased/deprecated"]{Deprecated}

 @subsubsection[#:tag "changelog/unreleased/removed"]{Removed}

 @subsubsection[#:tag "changelog/unreleased/fixed"]{Fixed}

 @subsubsection[#:tag "changelog/unreleased/security"]{Security}
}

@subsection[#:tag "changelog/0.0.2"]{0.0.2 · 2017-02-15}

@subsubsection[#:tag "changelog/0.0.2/added"]{Added}

@itemlist[
 @item{Truncate large feeds. Thanks Abdulvahid Işık for the bug report.}]

@subsection[#:tag "changelog/0.0.1"]{0.0.1 · 2017-02-09}

@subsubsection[#:tag "changelog/0.0.1/added"]{Added}

@itemlist[
 @item{Basic functionality.}]
