# Build Your Own SaaS with Docker

A proof of concept with a simple Memcached SaaS

See a demo of this application running at [memcachedasaservice.com](http://www.memcachedasaservice.com)

Read and download an updated version of this article on [SlideShare](http://www.slideshare.net/julienbarbier42/building-a-saas-using-docker)

## Introduction

### This is cs50

This document and source code are part of my final project for cs50x that I started on edx.org few months ago. For this final project I had several goals:
-  learn a new language: I chose to learn Ruby and Rails
-	use a new piece of technology. I chose to use [Docker](http://www.docker.io)
-	build a cool product. Building a SaaS a new way and with a new piece of technology sounds fun!
-	make it open source, and learn how to use Git and GitHub

Along the way I wrote several documents that are available on [SlideShare](http://www.slideshare.net/julienbarbier42/documents). Some of them have been used by Docker in their documentation.

### Proof of concept

By downloading the source code and reading this document you will be able to run a minimalist SaaS. Your users will be able to get their own Memcached server. Of course this is only a proof of concept, but it runs quite well.

### Memcached

Memcached is a free & open source, high-performance, distributed memory object caching system, generic in nature, but intended for use in speeding up dynamic web applications by alleviating database load. 

I chose Memcached because it is a widely used service. It is also easy to install and use, so that the tests are not too complicated to perform.

### Thank you!

I had only a few weeks to learn Ruby, Rails, Git, Github, Docker, iptables, sudoers, … and build this proof of concept. I would like to thank all the people who gave their time to help me and answer all my questions:
-	Guillaume Charmes, alias Cortex, alias MPM, my Docker teacher
-	Guillaume Luccizano, Steeve Morin and Sylvain Kalache, my Rails and Ruby teachers (sorry I was not able to use TDD until the end, I didn’t have enough time!)
-	Daniel Mizyrycki, my Git and GitHub teacher
-	Jerome Petazzoni, my iptables teacher
-	and Thomas Meson for giving me an Ubuntu server to play with

# Requirements

## Ubuntu machine

In order to follow this tutorial you will need a server with the last version of Ubuntu (or any other OS, but using Vagrant and VirtualBox to run an Ubuntu image). We need Ubuntu because our minimalist SaaS will use Docker, which runs on Ubuntu servers only.

The community behind Docker is growing fast and is very active. And at the time I write this document, it is now possible to use Docker on different operating systems. For instance, Flavio Castelli has written a blog-post on how to use [Docker on openSUSE](http://flavio.castelli.name/2013/04/12/docker-and-opensuse/). And I’ve seen people using it on CentOS during a Docker demo days.

## Docker

Docker is a Linux container runtime. It has been released few weeks ago as an open-source project by dotCloud. Docker complements LXC with a high-level API which operates at the process level. It runs unix processes with strong guarantees of isolation and repeatability across servers.

Please visit [Docker’s website](http://www.docker.io) for a tutorial on how to get Docker running on your Ubuntu machine or using Vagrant + VirtualBox on any other Operating system.

We will use only few Docker commands through this tutorial. To learn more about the Docker command line interface, you can take a look at their CLI documentation page.

## Memcached

You don’t need to have Memcached installed on your server. Memcached will run inside our Docker containers.

I will explain in this document how you can build your Memcached container. If you are not interested in learning how to build your own image, you can skip the first chapter, jump directly to the next chapter “Creating a Memcached SaaS” and use the image called jbarbier/memcached. To get this image, use the docker pull command:

`docker pull jbarbier/memcached`

# Creating a Docker image with Memcached

The first step to build the minimalist Memcached SaaS is to have an image of a container with Memcached installed.

## Start Docker

Let’s check if Docker is already running.

`ps aux | grep docker`

If you do not see a line “docker –d”, then start Docker as a daemon:

`sudo docker –d &`

## Installing Memcached on Docker

We will install Memcached on a Docker container with the docker run command.

`docker run -d base apt-get -y install memcached`

This command will return you the id of the new created container running your command will need to keep this id in order to use it later. In our example, the id is f1ab59fbc9d5.
We can check that the installation is complete by using the command docker logs with the container id given by the previous command.

`docker logs f1ab59fbc9d5 | less`

*Remember to replace f1ab59fbc9d5 by your container id.*

## Committing our Memcached container

We can commit our new container with the docker commit command, using our container id. With the following command line we will name it jbarbier/memcached, but you should use your own name.

`docker commit f1ab59fbc9d5 jbarbier/memcached`

*Remember to replace f1ab59fbc9d5 by your container id and jbarbier/memcached by your own name.*

This command gives you back a new id, which is the image id of your committed container. In our example it is c3b6fcb48266.

## Checking our Memcached container image

Let’s check that Memcached is installed on this image. To do so we can spawn a new container from this image and run bash inside.

`docker run -i -t jbarbier/memcached /bin/bash`

*Remember to replace jbarbier/memcached with the name of your image.*

You should see a new prompt indicating that you are inside the container. Let’s see if Memcached is installed. Run

`memcached`

to make sure memcached is installed. You should get an error indicating that memcached can not be ran as root.

Note that you could have used the id of your image instead of the name of your repository.

`docker run -i -t c3b6fcb48266 /bin/bash`

*Remember to replace c3b6fcb48266 by your image id.*


## Playing with our Memcached image

Now that we have an image with Memcached installed, let’s use it :)

### Spawning a new container based on our Memcached image

`docker run -d -p 11211 jbarbier/memcached memcached -u daemon`

*Remember to replace jbarbier/memcached with the name of your image.*

We need to launch Memcached with the –u option because you can not run it as root. With –u daemon, our Memcached will run as a daemon.
In the next chapter we will build a SaaS with this image. So we will need any user to be able to access their Memcached. In order to be able to use the Memcached server running in the container from outside our server, we can use the –p option. This option tells Docker to map the internal port of the container used by Memcached (11211), with a public port of the host.

As usual, Docker gives you back the id of the container you launched. In our case it is c360f228e22f.

### Retrieving the public port of our Memcached container

In order to use Memcached from outside the localhost we need to know the host public port mapped by Docker. In order to know that we can use the docker inspect command.

`docker inspect c360f228e22f`

*Remember to replace c360f228e22f by your container id before running this command.*

This will give you a JSON output with plenty of configuration details.
In the NetworkSettings/PortMapping you will find the public port you can use Memcached with from outside the server. In our case the public port is 49153. 

### Testing our Memcached 

Let’s test and use our Memcached service, from an outside machine. In the following examples I will use 142.242.242.42 as the IP of the server where the container is running, and 49153 as the public port.
Before running any of these examples be sure to replace the IP with your server IP, and the port number with the one docker inspect gave you.

#### Ruby

    # run gem install dalli first
    require 'dalli'
    ip = '142.242.242.42'
    port = 49153
    dc = Dalli::Client.new("#{ip}:#{port}")
    dc.set('abc', "Always Be Closing")
    value = dc.get('abc')
    puts value

This script should give you the following output:

`Always Be Closing`

#### Python

    # pip install python-memcached
    import memcache
    ip = '142.242.242.42'
    port = 49153
    mc = memcache.Client(["{0}:{1}".format(ip, port)], debug=0)
    mc.set("best_dev", "Guillaume C.") value = mc.get("best_dev")
    print value

This script should give you the following output:

`Guillaume C.`

# Creating a Memcached SaaS

Now that we have an image with Memcached installed, and that we know almost all the required commands, the plan is to use that to create our SaaS. Each user will have its own Memcached running inside his own container.

1.  A user registers through our website
2.	We spawn a Memcached container using our image
3.	We give the user an IP and a port of his Memcached server
4.	We add a layer of security

This last step is required because otherwise everybody could use the user’s Memcached since there is no built-in security for Memcached servers.

## Building the website

As I previously mentioned I chose to learn Ruby and Rails, so the website is using these technologies, but you could use any language.
Since this article is not about building websites we won’t go into details on how to build a website. Feel free to use my code or to build your own website with your favorite language and database.

The example website does only handle sign-up, sign-in and a profile page which displays information about the user’s Memcached server. These are the only required pages in order to build this proof of concept.

## Spawning a Memcached container on registration

When the user has signed-up, we need to run the commands to launch a new container with our Memcached image. The function create_memcached_instance is doing all the job. You can find this function in the file users_controller.rb

    def create_memcached_instance
      docker_path = '/home/julien/docker-master/'
      container_id = `#{docker_path}docker run -d -p 11211 jbarbier/memcached memcached -u daemon`
      cmd = "#{docker_path}docker inspect #{container_id}"
      json_infos = `#{cmd}`
      i = JSON.parse(json_infos)
      @user.memcached = i["NetworkSettings"]["PortMapping"]["11211"]
      @user.container_id = container_id
      @user.docker_ip = i["NetworkSettings"]["IpAddress"]
    end

If you have cloned the repository and are running the website from that, remember to edit users_controller.rb and set the docker_path variable to your Docker’s path. Alternatively you can add Docker to your PATH.

Let’s go through all the lines:

    docker_path = '/home/julien/docker-master/'

docker_path should contain the path of your Docker’s executable

    container_id = `#{docker_path}docker run -d -p 11211 jbarbier/memcached memcached -u daemon`

As discussed in the previous chapter, ``docker run -d`` runs a command in a new container. We pass the option -d so that it leaves the container run in the background.

The option ``-p 11211`` maps the internal port of the container used by Memcached with a public port of our server.

``jbarbier/memcached`` is the name of our image with Memcached installed (see previous chapter to see how we built this image). If you have created your own image, you should replace ``jbarbier/memcached`` by the name of your image.

memcached -u daemon is the command we run inside the new container. We use the option -u daemon to run Memcached with user daemon. The command docker run  returns the id of the new container. We will need it so we save it to the variable container_id.

    cmd = "#{docker_path}docker inspect #{container_id}"

As discussed earlier, we need to get the public port to give it to the user. So we inspect our newly created container with the docker inspect command. We pass it the ``container_id`` variable to tell Docker which container to inspect. This command returns us lots of information about the container formatted in JSON. We save it and 

    i = JSON.parse(json_infos)

we parse it to access the information. We then store all the required information into the user variable.

    @user.memcached = i["NetworkSettings"]["PortMapping"]["11211"]

``i["NetworkSettings"]["PortMapping"]["11211"]`` contains the public port mapped with the port 11211, used by Memcached.

    @user.container_id = container_id

saves the container id and

    @user.docker_ip = i["NetworkSettings"]["IpAddress"]

saves the internal IP address of our container. We will need this IP when we will be adding a basic layer of security on top of the user’s Memcached service.

## Displaying the public Memcached IP and port to the user

We now have to give the user the IP and port with which he can access his Memcached. The code to show these information is in the file show.html.erb.

    <% provide(:title, @user.email) %>
    <h1>
      <%= gravatar_for @user %>
      <%= @user.email %>
    </h1>
    <div class="alert alert-info">
      Congratulations <%= @user.email %>. Your Memcached server is ready to use.
    </div>
    <h1>Your Memcached Server is ready!</h1>
    <div class="block-info">
      <h3>IP: <%= my_public_ip %></h3>
      <h3>PORT: <%= @user.memcached %></h3>
    </div>
    <div class="alert alert-info">
      Use it with your favorite language.
    </div>
    <%= render 'code' %>
    <%= render 'ip' %>

### Port

We already have the port saved. We just need to display it

    PORT: <%= @user.memcached %>

### IP address    

We just need to know our public IP address (the IP of our server). There are plenty of ways to know it. One of which is to ask an online service. I chose to use ``ifconfig.me`` but you could use any service of this type. The code to discover its own public IP address is in the file users_helper.rb.

    def my_public_ip
        @@ip ||= Net::HTTP.get_response(URI.parse("http://ifconfig.me/ip")).body.chomp
    end

``http://ifconfig.me/ip`` simply returns the IP. So we just have to store it and then show it to the user.

    IP: <%= my_public_ip %>

Alternatively, if you just want to test, you can hard code your IP address in ``my_public_ip`` or even in show.html.erb.

At this point you should have all you need to build your own Memcached SaaS.

If you cloned my this repository, after the registration you should see the Profile’s page showing the IP and port whith which you can access your Memcached.

You can also check that a new container is running every time a new user registers.

    julien@cs50:~$ ps aux | grep docker
    root     23863  0.0  0.0  27540  1220 ?        S    Apr11   0:00 lxc-start -n 48610f83f354bd5a7675bf41daedbb87958e6acf618f8c24487526373ddde8b8 -f /var/lib/docker/containers/48610f83f354bd5a7675bf41daedbb87958e6acf618f8c24487526373ddde8b8/config.lxc -- /sbin/init -g 172.16.42.1 -- memcached -u daemon
    […]

## Adding security

We have now a minimalist Memcached SaaS. But our users are not happy because anybody can access their Memcached server. So we need to give the option to our users to restrict somehow the access to their Memcached. There are plenty of ways to do so. In this tutorial we will give the user the option to restrict the access to the Memcached to one IP. And to do so we will use iptables.

### Using iptables to filter by IP

Iptables is used to set up, maintain, and inspect the tables of IPv4 packet filter rules in the Linux kernel. The command lines to restrict the access to the service to one IP address is in the file add_ip 

    #!/bin/sh
    
    /sbin/iptables -I FORWARD -d $1 -s $2 -j ACCEPT
    /sbin/iptables -A FORWARD -d $1 -j DROP

``add_ip`` is an executable shell script. That is why we have 

    #!/bin/sh

at the beginning of the file. The script will take two arguments in parameters.
``$1`` is the internal IP of the container that we previously stored in ``@user.docker_ip`` upon user account creation.
``$2`` is the IP provided by the user which will become the only authorized IP to access the user’s container, and the user’s Memcached server.

    /sbin/iptables -I FORWARD -d $1 -s $2 -j ACCEPT

Tells iptables to add a rule to accept IP ``$2`` to access internal IP ``$1``.

    /sbin/iptables -A FORWARD -d $1 -j DROP

Tells iptables to add a rule to deny all access to IP ``$1`` from any IP.
Since the first rule is “checked” first, only IP ``$2`` will be able to access IP ``$1``.

The file ``remove_ip`` does exactly the opposite using the –D option to delete the previous rules.

    #!/bin/sh
    /sbin/iptables -D FORWARD -d $1 -s $2 -j ACCEPT
    /sbin/iptables -D FORWARD -d $1 -j DROP

NOTE: Be sure that users do not have write access to these files.

### Calling iptables from a web server

We call the previous scripts from the two following functions in users_controller.rb

      def iptables_add_ip(i)
        cwd = Dir.pwd
        `sudo #{cwd}/iptables/add_ip #{@user.docker_ip} #{i}`
      end

      def iptables_remove_ip(i)
        cwd = Dir.pwd
        `sudo #{cwd}/iptables/remove_ip #{@user.docker_ip} #{i}`
      end

But in order to use iptables we need to have root privileges. And our web server is probably not running as root (and it should not). So we will need to use the sudo command and allow our webserver to run the two scripts.

To do so we will use /etc/sudoers. The /etc/sudoers file controls who can run what commands as what users on what machines and can also control special things such as whether you need a password for particular commands.

A simple way to tackle our problem is to create a new file in /etc/sudoers.d. We can call it saas_memcached for instance. 

    julien@cs50:~$ cat /etc/sudoers.d/saas_memcached
    Cmnd_Alias ADD_REM_IPS_CMDS = /home/julien/final_proj/SaaS_Memcached/iptables/add_ip, /home/julien/final_proj/SaaS_Memcached/iptables/remove_ip

    www-data ALL=(ALL) NOPASSWD: ADD_REM_IPS_CMDS

There are two lines in the file. The first line creates an alias of all the executable files and the second allow the user ``www-data`` to run these executable files with root privilege without requiring typing any password. 

You should replace ``/home/julien/final_proj/SaaS_Memcached`` by the root of your website. If your server does not run as ``www-data``, simply replace ``www-data`` by the right user in the file.

Now the user should be able to specify the allowed IP from which he can access Memcached. Every other IP address will be blocked.

### Testing the security filter

In order to test our security filter, let’s create an account with the email ``thisis@cs50.com`` to launch a new Memcached server. Copy the example PHP code to one computer, and the Ruby code to antoher computer on another network.
In the following examples we will run the ruby script from IP ``69.42.42.42`` and the PHP script from IP ``69.33.33.33``.

If we run we run these scripts from our two IPs it will work.

With the first computer:

    Guillotine:test_memcached jbarbier$ ruby ip_ok.rb
    Welcome thisis@cs50.com! Your Memcached server is ready to use :)

With the second computer

    julien@revolution:/tmp$ php ip_nok.php 
    Welcome thisis@cs50.com! Your Memcached server is ready to use :)


Let’s scroll to the bottom of the profile page and add the IP ``69.42.42.42`` so our Memcached access can be restricted to this IP.

After saving the IP, we should check that the access is really restricted to the IP ``69.42.42.42``.

Running the Ruby script from ``69.42.42.42``

    Guillotine:test_memcached jbarbier$ ruby ip_ok.rb
    Welcome thisis@cs50.com! Your Memcached server is ready to use :)

Running the PHP script from ``69.33.33.33``

    julien@revolution:/tmp$ php ip_nok.php 
    PHP Notice:  Memcache::connect(): Server 137.116.225.4 (tcp 49164, udp 0) failed with: Connection timed out (110) in /tmp/ip_nok.php on line 6
    PHP Warning:  Memcache::connect(): Can't connect to 137.116.225.4:49164, Connection timed out (110) in /tmp/ip_nok.php on line 6
    […]

As we can see only the script ran from IP ``69.42.42.42`` is able to connect to Memcached.

Let’s check the iptables by running ``iptables –L``

    julien@cs50:~$ sudo iptables -L
    [sudo] password for julien:
    Chain INPUT (policy ACCEPT)
    target     prot opt source               destination
    
    Chain FORWARD (policy ACCEPT)
    target     prot opt source               destination
    ACCEPT     all  --  c-69-42-42-42.hsd1.ca.comcast.net  172.16.42.14
    DROP       all  --  anywhere             172.16.42.14
    
    Chain OUTPUT (policy ACCEPT)
    target     prot opt source               destination

The two lines

    ACCEPT     all  --  c-69-42-42-42.hsd1.ca.comcast.net  172.16.42.14
    DROP       all  --  anywhere             172.16.42.14

Have been added by our add_ip script to restrict the access of ``thisis@50.com``’s container running Memcached.

We can verify that the the IP ``172.16.42.14`` is the right internal IP of the container by using the ``docker inspect`` command on the container id. We saved this id into ``@user.container_id`` during registration (see users_controller.rb). Let’s retrieve this id from the database.

    julien@cs50:~/final_proj/SaaS_Memcached$ sqlite3 db/www.sqlite3
    SQLite version 3.7.13 2012-06-11 02:05:22
    Enter ".help" for instructions
    Enter SQL statements terminated with a ";"
    sqlite> select container_id from users where email = 'thisis@cs50.com';
    190c7d70fbc1

*Be sure to replace ``www.sqlite3`` by your database.*

On our server, the id of ``thisis@50.com``’s container is ``190c7d70fbc1``. To check the IP of the container we can use the ``docker inspect`` command.

Be sure to replace ``190c7d70fbc1`` by the right container id that the SQL request gave you during the last step.

As expected the IP address is ``172.16.42.14`. If you do the same on your server be sure that this IP matches the one shown in the iptables listing.

_Congratulations!_ You are now running a Memcached SaaS, with a simple security layer. Congratulations!

# Where to go from here

We’ve seen how to run Memcahed as a service with Docker. But you could create your own container image, running another service. John Costa did write an article on how to install [Redis on Docker](http://www.johnmcostaiii.net/2013/installing-redis-on-docker/) for instance. But you could create an image running any service (MySQL, MongoDB, PHP, …), and then build a SaaS using this container image.

Why should we offer only one type of service on our SaaS? We could offer multiple services. We could simply add a new table “services” to the database so that our users could be able to have multiple services. And we could add an admin page in order to list, activate and deactivate the available services.

The website shown in this example is very basic. We could easily improve it. We could for instance:
-   add an admin page to list users and delete/suspend them
-	let users change recover and change their password
-	let users delete their account
-	let user restart their Memcached server
-	let the user specify the memory limit he needs (using run docker –m) 
-	let the user know how much memory he uses
-	add a payment gateway to make our customer pay for the service
-	…

You can also add more security, scalability, etc… but this will be another story :) 

I hope you had fun playing with this article. Feel free to [contact me](https://twitter.com/julienbarbier42) if you have any question.

Happy SaaSing!

To be continued...

[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/jbarbier/saas_memcached/trend.png)](https://bitdeli.com/free "Bitdeli Badge")
