# codehearts [![Build Status](https://travis-ci.com/codehearts/codehearts.svg?branch=master)](https://travis-ci.com/codehearts/codehearts)

My personal portfolio site, served statically and cooked up with Jekyll

## Development

For local development, use Docker Compose to automatically compile and serve your work. Results will be available on [localhost:80](http://localhost)

```
docker-compose up -d
```

Deployment occurs automatically when the build for a commit on `master` succeeds

### Files

- `_config.yml` Jekyll configuration
- `_bios/` Bios for human beings (just me honestly)
- `_layouts/` Layout templates for pages to use
  - `codehearts.html` The base page template, containing the document head and body w/ footer
  - `pdf.html` The page template for PDF documents
- `_plugins/` Extensions for Jekyll
  - `jekyll-gotenberg.rb` Converts pages with `pdf` set in their front matter to PDF during site generation
- `_repos/` Featured GitHub repos
- `_sass/` Sass files to compile and access from the `css/` directory
- `_works/` Featured completed works, with images
- `css/` CSS files to copy to the site output
  - `codehearts.scss` The base site stylesheet
  - `pdf.scss` The PDF stylesheet, containing print-oriented styles
- `docker-compose.yml` Local development and CI build environment
- `.deploy.key.enc` Encrypted private key for server `deploy` user
- `.travis.yml` Builds, verifies site integrity, and deploys `master` to production

### Bios

Bios take a brief description and have the following front matter:

- `name` Name or title
- `image` 470px wide image
- `image_alt` Accessibility text for `image`
- `links` Array of links with the following properties
  - `name` Name of the link, and label for the button
  - `link` URL for the link

### Repos

Repositories take a super short description and have the following front matter:

- `name` Human readable name, with apostrophes and spaces instead of dashes
- `repo` GitHub repo with the username and repo name, like `codehearts/codehearts`

Repos are displayed in the sorted order of their filenames, so each file is prepended with a number to influence the sorting

### Works

Works take a brief to moderate description and have the following front matter:

- `name` Name or title
- `time` Full month name and year, or a range if the work had a start/end
- `link` Optional URL for the work
- `link_label` Optional button label for the work's URL, if the URL itself isn't acceptable
- `image` 1024px wide image, 1152px tall to maintain the 8/9 ratio I seem to be using
- `image_alt` Screenshot of my CIF home page design

Works are displayed in the _reverse_ sorted order of their filenames, so each file is prepended with a number to influence the sorting

## Setup

Assuming an Ubuntu server, configure as follows:

- Install prerequisite software
  - `add-apt-repository ppa:certbot/certbot`
  - `apt-get update && apt-get install nginx python-certbot-nginx`
- Create a non-root user with sudo and web server permissions
  - `adduser -G sudo,www-data katie`
- Create a deployment user which can only sign in via key over SSH
  - `adduser --disabled-password --gecos '' deploy`
  - Create an SSH key for the deployment user on your local machine
    - `ssh-keygen -t rsa -f .deploy.key`
  - Append the contents of `.deploy.key.pub` on your local machine to `/home/deploy/.ssh/authorized_keys`
  - Encrypt the private key on your local machine for Travis CI
    - `travis encrypt-file --com --add .deploy.key && chmod 600 .deploy.key.enc`
- Configure the firewall to allow only SSH and HTTP/HTTPS traffic
  - `ufw default deny incoming && ufw allow OpenSSH && ufw allow 'Nginx Full' && ufw enable`
- Create a server block for the domain, accessible only by the deployment user
  - `mkdir -p /var/www/codehearts.com/html/ && chown deploy:www-data /var/www/codehearts.com/html/`
  - Create `/etc/nginx/sites-available/codehearts.com` with the following contents:

        # Cache-Control mapping
        map $sent_http_content_type $expires {
          default                    off;
          text/html                  epoch;
          text/css                   max;
          application/javascript     max;
          ~image/                    max;
        }

        server {
          root /var/www/codehearts.com/html;
          index index.html;
          expires $expires;

          server_name codehearts.com www.codehearts.com;

          location / {
            try_files $uri $uri/ =404;
          }
        }
  - `ln -s /etc/nginx/sites-available/codehearts.com /etc/nginx/sites-enabled/`
- Configure SSL
  - `certbot --nginx -d codehearts.com -d www.codehearts.com --agree-tos --redirect`
- Enable ssh for the non-root user
  - `su - katie -c 'mkdir ~/.ssh/ && vim ~/.ssh/authorized_keys'`
- Disable the root user
  - `passwd -l root`
  - Edit `/etc/ssh/sshd_config` and set `PermitRootLogin` to `no`
