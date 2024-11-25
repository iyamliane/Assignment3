# Assignment 3 Part 1 #

## Table of Contents

1. [Introduction](#introduction)
2. [Requirements](#requirements)
3. [Task 1: Setting up System User / Directory Structure](#task-1-setting-up-system-user--directory-structure)
4. [Task 2: Creating And Configuring `systemd` Service + Timer](#task-2-creating-and-configuring-systemd-service--timer)
5. [Task 3: Nginx Configuration](#task-3-nginx-configuration)
6. [Task 4: Installing and Configuring ufw for SSH and HTTP](#task-4-installing-and-configuring-ufw-for-ssh-and-http)
7. [Task 5: Verification of Setup / Completion](#task-5-verification-of-setup--completion)
8. [References](#references)

## Introduction ## 

The objective of this assignment is to build and configure a system that will generate a static `index.html` file that will show your system information. The script that is scheduled to be ran daily at 5:00 AM through the usage of a `systemd` service/timer. Nginx will be configured to serve the HTML file on the Arch Linux server. Lastly, the server will be protected with a fireall using `ufw`. 

## Requirements ##
Please ensure that the following requirements are met before getting started: 

- Operating System: Arch linux 
- Permissions: Root access to run scripts
- Working Directory: All commands in this guide are executed from user's home
- Packages: `nginx` and `ufw` must be installed

## Task 1: Setting up System User / Directory Structure ##

1) To run the following command to create a system user with a home directory in `/var/lib/webgen` without a shell login: 

`sudo useradd -r -d /var/lib/webgen -s /usr/sbin/nologin webgen`

**Code Explanation:**

The command creates a system user named webgen with the following properties:
- The user’s home directory is set to /var/lib/webgen.
- The user is not allowed to log in interactively (/usr/sbin/nologin).
- It is a system user (used for service-related tasks)

> Using a system user for this task is recommended as it enhances security by preventing interactive logins which will in turn reduce the risks as opposed to using a regular user/root.

2) Create a home directory structure:

`sudo mkdir /var/lib/webgen/bin `

`sudo mkdir /var/lib/webgen/HTML`

3) Git clone the generate_index script:

`git clone https://git.sr.ht/~nathan_climbs/2420-as2-start`

4) Copy generate_index script to the working directory:

`sudo cp 2420-as2-start/generate_index /var/lib/webgen/bin`

5) Give webgen ownership and make the script executable

`sudo chown -R webgen:webgen /var/lib/webgen`

`sudo chmod 700 /var/lib/webgen/bin/generate_index`

## Task 2: Creating And Configuring `systemd` Service + Timer ## 

1) Create generate-index.service file

`sudo nvim /etc/systemd/system/generate-index.service`

Add the following to the script: 

````
[Unit]
Description= Generate Index Service File

[Service]
Type=simple
User=webgen
Group=webgen
ExecStart=/var/lib/webgen/bin/generate_index
````
2) Create generate-index.timer file

`sudo nvim /etc/systemd/system/generate-index.timer`

Add the following to the script: 

````
[Unit]
Description=The generate_index script is ran daily at 5:00AM.

[Timer]
OnCalendar=*-*-* 05:00:00
Unit=generate-index.service
Persistent=true

[Install]
WantedBy=timers.target
````
3) Start the timer:

`sudo systemctl start generate-index.timer`

4) Enable the timer so that the timer automatically starts upon system boot: 

`sudo systemctl enable generate-index.timer`

5) To check if the timer is active:

`systemctl status generate-index.service`

`systemctl status generat-index.timer`

## Task 3: Nginx Configuration ##

1) Install Nginx: 

`sudo pacman -Syu nginx`

2) Open the Nginx configuration file: 

`sudo nvim /etc/nginx/nginx.conf`

3) Change the file and add the following: 

Default user should be `webgen` 

 ![ user webgen ](/images/user-webgen.png)

 4) Create new directory for custom configuration files:

 `sudo mkdir -p /etc/nginx/sites-available`
 
 `sudo mkdir -p /etc/nginx-sites-enabled`

5) Create configuration file for server block: 

`sudo nvim /etc/nginx/sites-available/webgen.conf`

6) Add the following code for the server block configuration: 

````
server {
   listen 80;
   server_name local-webgen;

   root /var/lib/webgen/HTML;
   index index.html;

   location / {
      try_files $uri $uri/ =404;
   }
}
````
**Explanation of code**: 
- `Server`: Defines a server block, which specifies how Nginx should handle requests for a particular site or domain.

- `Listen 80` : Configures the server to listen on port 80, the default port for HTTP traffic.

- `root /var/lib/webgen/HTML` :
Specifies the root directory for the server’s files.
Files will be served from /var/lib/webgen/HTML. For example, if a user requests /index.html, Nginx will look for the file at /var/lib/webgen/HTML/index.html.

- `index index.html`: Sets the default file to serve when a directory is requested.

- `try_files $uri $uri/ =404;` : 
Tells Nginx how to handle requests for files:
First, try to serve the exact file ($uri).
If that fails, try to serve it as a directory ($uri/).
If neither exists, return a 404 Not Found error.


7) Create a symbolic link for the new configuration:

`sudo ln -s /etc/nginx/sites-available/webgen.conf /etc/nginx/sites-enabled`

8) Start Nginx:

`sudo systemctl start Nginx`

9) Check the status:

`sudo systemctl status Nginx`

## Task 4: Installing and Configuring ufw for SSH and HTTP ##

1) Install ufw:

`sudo pacman -Syu ufw`

>**NOTE**: Please MAKE SURE YOU DO NOT ENABLE ufw immediately after installation to prevent risk of getting locked out of your SSH connection. 

2) Allow SSH/HTTP access:

`sudo ufw allow ssh`

`sudo ufw allow http`

3) Enable rate limiting (enhances security and protects against authorized access attempts): 

`sudo ufw limit ssh`

4) Once steps have been completed above enable ufw:

`sudo ufw enable`

5) Check the status of ufw: 

`sudo ufw status`

It should look like this: 

 ![ user webgen ](/images/sudo-ufw-status.png)

## Task 5: Verification of Setup / Completion ##

After everything has been completed, please locate your droplet IP address (it can be found by looking at your droplet on digital ocean) and put it in your browser. It should display your system information- then take a screenshot. 

 ![ user webgen ](/images/image.png)

### References
- [Arch Linux Wiki - User Management](https://wiki.archlinux.org/title/Users_and_groups)
- [Arch Linux Wiki - systemd Timers](https://wiki.archlinux.org/title/Systemd/Timers)
- [Arch Linux Wiki - UFW (Uncomplicated Firewall)](https://wiki.archlinux.org/title/UFW)
- [Nginx Documentation - Beginner's Guide](https://nginx.org/en/docs/beginners_guide.html)
- [Nginx Configuration - Try_Files Directive](https://nginx.org/en/docs/http/ngx_http_core_module.html#try_files)
- [DigitalOcean - Droplet Management](https://docs.digitalocean.com/products/droplets/how-to/manage/)
- [Systemd Timer Unit Documentation](https://www.freedesktop.org/software/systemd/man/systemd.timer.html)
- [Linux Command - Useradd Manual](https://man7.org/linux/man-pages/man8/useradd.8.html)
