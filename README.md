mysql
=====
Docker image for mysql server 

Building the image
------------------
`make`

or manually

`docker build -t user/name:tag .`

Running the image
-----------------
`docker run -d -p 3306:3306 rokkie/mysql`

