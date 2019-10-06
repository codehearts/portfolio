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
- `_resumes/` Resumé data
- `_sass/` Sass files to compile and access from the `css/` directory
- `_works/` Featured completed works, with images
- `css/` CSS files to copy to the site output
  - `codehearts.scss` The base site stylesheet
  - `pdf.scss` The PDF stylesheet, containing print-oriented styles
- `icons/` Site icons, such as the favicon and Apple touch icon
  - `safari-pinned-tab.svg` Pinned tab icon for Safari, doubles as the favicons' source image
- `docker-compose.yml` Local development and CI build environment
- `.deploy.key.enc` Encrypted private key for server `deploy` user
- `.travis.yml` Builds, verifies site integrity, and deploys `master` to production

### Bios

Bios take a brief description and have the following front matter:

- `name` Name or title
- `image` 470px wide image suffixed with `-2x`
  - Create a half-sized image without the `-2x` suffix `convert image-2x.png -scale=50% image.png`
  - Create a webp for both sizes `cwebp image.png -o image.webp && cwebp image-2x.png -o image-2x.webp`
- `image_alt` Accessibility text for `image`
- `links` Array of links with the following properties
  - `name` Name of the link, and label for the button
  - `link` URL for the link

### Repos

Repositories take a super short description and have the following front matter:

- `name` Human readable name, with apostrophes and spaces instead of dashes
- `repo` GitHub repo with the username and repo name, like `codehearts/codehearts`

Repos are displayed in the sorted order of their filenames, so each file is prepended with a number to influence the sorting

### Resumés

Resumés contain only the following front matter:

- `name` Who the resumé is for (basically just me)
- `links` Array of contact links with the following properties
  - `name` Label for the link
  - `link` URL for the link
- `experiences` Array of prior work experience
  - `position` Title of the position held
  - `location` Name of the workplace
  - `start` Start year
  - `end` End year, defaults to "current"
  - `notes` Array of notes about the experience
- `education` Array of schools with the following properties
  - `where` Name of the school
  - `what` Degree obtained
  - `when` Year of graduation
- `technologies` Array of technology experience with the following properties
  - `experienced` Array of technologies you're experienced with
  - `familiar` Array of technologies you're less experienced with
  - `interested` Array of technologies you're interested in learning
- `references` Array of references with the following properties
  - `name` Name of the reference
  - `relation` Position and company, or relationship to the reference
  - `link`: URL to contact the reference
  - `link_label` Label for the reference's contact link

### Works

Works take a brief to moderate description and have the following front matter:

- `name` Name or title
- `time` Full month name and year, or a range if the work had a start/end
- `link` Optional URL for the work
- `link_label` Optional button label for the work's URL, if the URL itself isn't acceptable
- `image` 1024px wide image, 1152px tall to maintain the 8/9 ratio I seem to be using, suffixed with `-2x`
  - Create a half-sized image without the `-2x` suffix `convert image-2x.png -scale=50% image.png`
  - Create a webp for both sizes `cwebp image.png -o image.webp && cwebp image-2x.png -o image-2x.webp`
- `image_alt` Screenshot of my CIF home page design

Works are displayed in the _reverse_ sorted order of their filenames, so each file is prepended with a number to influence the sorting

## Setup

Assuming an Ubuntu server, configure as follows:

- Install prerequisite software

        apt-get update && apt-get install nginx gnupg2

        # Install certbot-auto
        wget -P /usr/local/bin/ https://dl.eff.org/certbot-auto
        chown root /usr/local/bin/certbot-auto && chmod 0755 /usr/local/bin/certbot-auto

        # Verify the integrity of certbot-auto
        wget -N https://dl.eff.org/certbot-auto.asc
        gpg2 --keyserver pool.sks-keyservers.net --recv-key A2CFB51FA275A7286234E7B24D17C995CD9775F2
        gpg2 --trusted-key 4D17C995CD9775F2 --verify certbot-auto.asc /usr/local/bin/certbot-auto

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
- Secure Nginx by modifying `/etc/nginx/nginx.conf`
  - Set `server_tokens off` under basic http settings to remove the Nginx version from headers
  - Set `keepalive_timeout 15`
  - Add the following lines to reduce maximum buffer sizes and timeouts

        ##
        # Buffers
        ##
        client_body_buffer_size 1k;
        client_header_buffer_size 1k;
        client_max_body_size 1k;
        large_client_header_buffers 2 1k;

        ##
        # Timeouts
        ##
        client_body_timeout 12;
        client_header_timeout 12;
        send_timeout 10;

- Disable unnecessary Nginx modules

        rm /etc/nginx/modules-enabled/50-mod-{http-geoip,http-image-filter,http-xslt-filter,mail}.conf

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
          error_page 401 403 404 /index.html;

          location / {
            try_files $uri $uri/ =404;
          }

          if ($request_method !~ ^(GET|HEAD|POST)$ ) {
            return 405;
          }
        }
  - `ln -s /etc/nginx/sites-available/codehearts.com /etc/nginx/sites-enabled/`
- Configure SSL
  - `certbot-auto --nginx -d codehearts.com -d www.codehearts.com --agree-tos --redirect --must-staple --staple-ocsp --http2 --hsts --rsa-key-size=4096`
- Enable ssh for the non-root user
  - `su - katie -c 'mkdir ~/.ssh/ && vim ~/.ssh/authorized_keys'`
- Disable the root user
  - `passwd -l root`
  - Edit `/etc/ssh/sshd_config` and set `PermitRootLogin` to `no`
- Useful tools
  - [webhint](https://webhint.io)
  - [PageSpeed](https://developers.google.com/speed/pagespeed/insights/)
  - [SSL Labs Server Test](https://www.ssllabs.com/ssltest/)
  - [Mozilla SSL Configuration Generator](https://ssl-config.mozilla.org/#server=nginx)
