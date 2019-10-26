# Production Setup

Assuming an Ubuntu server, configure as follows:

- Uncomment the `deb-src` line for the main security repo in `/etc/apt/sources.list`
- Install prerequisite software

        apt-get update \
          && apt-get install nginx libpcre3-dev zlib1g-dev libssl-dev libxslt1-dev libgd-dev libgeoip-dev git gnupg2 \
          && apt-get source nginx

        # Build and install the nginx brotli module
        git clone https://github.com/google/ngx_brotli.git
        cd ngx_brotli/
        git submodule update --init
        cd ../nginx-*/
        # Provide the same arguments as `nginx -V`
        ./configure --add-dynamic-module=../ngx_brotli
        make modules
        mv objs/ngx_http_brotli_static_module.so /usr/share/nginx/modules/
        echo 'load_module modules/ngx_http_brotli_static_module.so;' > /etc/nginx/modules-available/50-mod-brotli.conf
        ln -s /etc/nginx/modules-available/50-mod-brotli.conf /etc/nginx/modules-enabled/
        cd ..
        rm -rf nginx* ngx_brotli

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
  - `adduser --disabled-password --gecos '' -G www-data deploy`
  - Create an SSH key for the deployment user on your local machine
    - `ssh-keygen -t rsa -f .deploy.key`
  - Append the contents of `.deploy.key.pub` on your local machine to `/home/deploy/.ssh/authorized_keys`
  - Encrypt the private key on your local machine for Travis CI
    - `travis encrypt-file --com --add .deploy.key && chmod 600 .deploy.key.enc`
- Configure the firewall to allow only SSH and HTTP/HTTPS traffic
  - `ufw default deny incoming && ufw allow OpenSSH && ufw allow 'Nginx Full' && ufw enable`
- Edit `/etc/nginx/mime.types` and add `application/manifest+json webmanifest`
- Secure Nginx by modifying `/etc/nginx/nginx.conf`
  - Set `server_tokens off` under basic http settings to remove the Nginx version from headers
  - Set `keepalive_timeout 15`
  - Set `gzip off`, `gzip_static on`, and `gzip_vary on`
  - Set `brotli_static on`
  - Add `charset utf-8` and `charset_types text/css application/javascript application/manifest+json`
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
  - `mkdir -p /var/www/codehearts.com/html/ && chown deploy:www-data /var/www/codehearts.com/html/ && chmod g+ws -R /var/www/codehearts.com/html/`
  - Create `/etc/nginx/sites-available/codehearts.com` with the following contents:

        # Cache-Control mapping
        map $sent_http_content_type $expires {
          default                    off;
          text/html                  epoch;
          text/css                   max;
          application/javascript     max;
          application/manifest+json  max;
          ~image/                    max;
        }

        server {
          root /var/www/codehearts.com/html;
          index index.html;
          expires $expires;

          server_name codehearts.com www.codehearts.com;
          error_page 401 403 404 /index.html;

          add_header X-Content-Type-Options nosniff;

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
