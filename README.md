1. INTRODUCCIÓN 
  A partir de un archivo YAML que leemos con Python, el servidor maestro instalará los 
  servicios apache y/o php dependiendo de la configuración establecida en el yaml.
  En caso de que en el servidor se encuentre en la lista de apache se le instalará dicho 
  servicio. En caso de que el servidor destino se encuentre en la lista de php, se le instalará 
  tanto apache como php.
  Si el servidor destino se cambia a apache, se le deberá de borrar el paquete php y apache 
  también para tener un apache limpio.

2. CONFIGURACIONES PREVIAS 
2.1. Sudoers 
     Hay que tocar el archivo sudoers de la máquina cliente para que un grupo (previamente 
     creado) al que pertenezca el usuario pueda ejecutar el programa apt sin necesidad de 
     ingresar la contraseña.
       %service_installer ALL=(root) NOPASSWD:/usr/bin/apt
     Hay que tocar el archivo sudoers de la máquina maestra para que el grupo (previamente 
     creado) al que pertenezca el usuario pueda ejecutar el script sh.
       %orchestra_conductor ALL=(root) NOPASSWD:/opt/apache+phpdeploy/apache+php-deploy.sh
2.2. Clave pública 
     Es necesario enviar la clave pública del usuario que ejecuta el script en la máquina 
     maestra a la máquina cliente mediante ssh-copy-id <usuario>@<ip> para poder 
     establecer conexiones ssh sin la necesidad de ingresar la contraseña del usuario de la 
     máquina cliente.
2.3. Python 
     Es necesario instalar Python (en este caso se ha instalado Python 3) en la máquina 
     maestra.
     También es necesario instalar la librería pyyaml para poder trabajar con yaml usando 
     Python. Por defecto esta distribución debian instala por defecto la librería al ejecutar la 
     instalación de python3. Si no se instalase, se podría hacer manualmente usando pip 
     install.

3. ARCHIVO YAML 
   Contenido del archivo servers.yaml:
   Defino dos clases de objetos (apache y php), las cuales tendrán varios objetos con un solo 
   atributo (ip).

4. ARCHIVO PYTHON 
4.1. Archivo php-deploy.php: 
     Importamos la biblioteca yaml y almacenamos en una variable el contenido del archivo 
     yaml. Después recorremos los objetos de la clase php y accedemos al valor de su 
     atributo ip.
4.2. Archivo apache-deploy.php: 
     Es igual que el anterior solo que esta vez recorremos los objetos de la clase apache en 
     vez de php.

5. ARCHIVO BASH 
5.1. Funciones 
     Defino dos funciones: apache_check() y php_check()
     - apache_check()
          Comprobará haciendo uso de ssh a la IP pasada por parámetro ($1) y mediante dpkg
          si tiene el programa apache2 instalado.
          En caso de no tenerlo actualizará los repositorios sin pedir confirmación (-y) e 
          instalará el paquete.
          Luego comprobará si tiene php instalado. Si lo tuviera borraría todos los paquetes, 
          configuraciones y archivos que estén relacionados con “php*” y “libapache2-
          mod-php*”. Además haría lo mismo con apache para poder hacer una instalación 
          limpia del mismo.
     - php_check()
          Comprobará si tiene instalado apache y si no lo tiene lo instalará. Luego comprobará 
          si tiene instalado php y si no lo tiene lo instalará.
5.2. Variables 
     Declaro 3 variables globales: $lista_apache, $lista_php y $log
     - lista_apache="$(python apache-deploy.py)"
          La cual recoge la salida al ejecutar el programa de python.
          La variable es una lista de IPs a las cuales se le quiere instalar apache (o desinstalar 
          php).
     - lista_php="$(python php-deploy.py)"
          La cual recoge la salida al ejecutar el programa de Python.
          La variable es una lista de IPs a las cuales se le quiere instalar php (en caso necesario 
          instalar apache también).
     - log="./apache+php-deploy.log"
          La cual dice dónde se generará el archivo log que guardará los datos de ejecución de 
          este script.
       
6. Inicio del log 
     Creamos el archivo log con un touch y le metemos la fecha de ejecución del programa.
     La fecha del programa reflejará en el log las veces que se ha ejecutado a lo largo del 
     tiempo este script
