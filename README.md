# Home Media Server setup files

Personal files and scripts to setup and run a home media server over a RaspberryPi 4 B, that includes:

* `init.sh`: To install and configure a default Debian installation, already accesible via SSH.
* `compose.yml`: To run all services through Docker containers. Currently has Jellyfin for shows, movies and music; Komga for comics, books and documents; Transmission for torrents; Soulseek for P2P sharing; and a WebDAV server.
* `webdav.dockerfile`: To build a custom Nginx image for the WebDAV service, because reasons.
* `nginx.conf`: Configuration to enable a full-feature WebDAV server.
* `healthcheck.sh`: Script to run a custom health checks on main services. **Under construction**.

**Not included:**
* `.htpasswd`: For WebDAV authentication, generated using `htpasswd`.
* `.env`: To setup all the variables needed by `init.sh`, `compose.yml` and `webdav.dockerfile`. An `env_example` file is included to use as a template.

----

###### Happy hack :)