# Build Your Own SaaS with Docker
A proof of concept with a simple Memcached SaaS


## Introduction

### This is cs50

This document and source code are part of my final project for cs50x that I started on edx.org few months ago. For this final project I had several goals:
-  learn a new language: I chose to learn Ruby and Rails
-	use a new piece of technology. I chose to use Docker
-	build a cool product. Building a SaaS a new way and with a new piece of technology sounds fun!
-	make it open source, and learn how to use Git and GitHub

Along the way I wrote several documents that are available on SlideShare. Some of them have been used by Docker in their documentation.

### Sources

You can find, clone, fork, or download the source code of the project on GitHub:
https://github.com/jbarbier/SaaS_Memcached

### Proof of concept

By downloading the source code and reading this document you will be able to run a minimalist SaaS. Your users will be able to get their own Memcached server. Of course this is only a proof of concept, but it runs quite well.

### Memcached

Memcached is a free & open source, high-performance, distributed memory object caching system, generic in nature, but intended for use in speeding up dynamic web applications by alleviating database load. 

I chose Memcached because it is a widely used service. It is also easy to install and use, so that the tests are not too complicated to perform.

### Thank you!

I had only a few weeks to learn Ruby, Rails, Git, Github, iptables, sudoers, … and build this proof of concept. I would like to thank all the people who gave their time to help me and answer all my questions:
-	Guillaume Charmes, alias Cortex, alias MPM, my Docker teacher
-	Guillaume Luccizano, Steeve Morin and Sylvain Kalache, my Rails and Ruby teachers (sorry I was not able to use TDD until the end, I didn’t have enough time!)
-	Daniel Mizyrycki, my Git and GitHub teacher
-	Jerome Petazzoni, my iptables teacher
-	and Thomas Meson for giving me an Ubuntu server to play with

# Requirements

## Ubuntu machine

In order to follow this tutorial you will need a server with the last version of Ubuntu (or any other OS, but using Vagrant and VirtualBox to run an Ubuntu image). We need Ubuntu because our minimalist SaaS will use Docker, which runs on Ubuntu servers only.

The community behind Docker is growing fast and is very active. And at the time I write this document, it is now possible to use Docker on different operating systems. For instance, Flavio Castelli has written a blog-post on how to use Docker on openSUSE. And I’ve seen people using it on CentOS during a Docker demo days.

## Docker

Docker is a Linux container runtime. It has been released few weeks ago as an open-source project by dotCloud. Docker complements LXC with a high-level API which operates at the process level. It runs unix processes with strong guarantees of isolation and repeatability across servers.

Please visit Docker’s website for a tutorial on how to get Docker running on your Ubuntu machine or using Vagrant + VirtualBox on any other Operating system.

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

As discussed in the previous chapter, docker run -d runs a command in a new container. We pass the option -d so that it leaves the container run in the background.

The option ``-p 11211`` maps the internal port of the container used by Memcached with a public port of our server.

``jbarbier/memcached`` is the name of our image with Memcached installed (see previous chapter to see how we built this image). If you have created your own image, you should replace jbarbier/memcached by the name of your image.

memcached -u daemon is the command we run inside the new container. We use the option -u daemon to run Memcached with user daemon. The command docker run  returns the id of the new container. We will need it so we save it to the variable container_id.

3.	cmd = "#{docker_path}docker inspect #{container_id}"

As discussed earlier, we need to get the public port to give it to the user. So we inspect our newly created container with the docker inspect command. We pass it the container_id variable to tell Docker which container to inspect. This command returns us lots of information about the container formatted in JSON. We save it and 

4.	i = JSON.parse(json_infos)

we parse it to access the information. We then store all the required information into the user variable.

5.	@user.memcached = i["NetworkSettings"]["PortMapping"]["11211"]

i["NetworkSettings"]["PortMapping"]["11211"] contains the public port mapped with the port 11211, used by Memcached.

6.	@user.container_id = container_id

saves the container id and

7.	@user.docker_ip = i["NetworkSettings"]["IpAddress"]

saves the internal IP address of our container. We will need this IP when we will be adding a basic layer of security on top of the user’s Memcached service.



# Build your own Memcached SaaS with Docker

This is a final project application fot [*CS50*](https://www.edx.org/courses/HarvardX/CS50x/2012/about).

This application will permit you to build a minimalist Memcached SaaS using [*Docker*](http://www.docker.io).

Docker install
-> install
-> create memcached image
-> 
