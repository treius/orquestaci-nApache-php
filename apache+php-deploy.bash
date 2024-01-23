#!/bin/bash
#----------------------------------------------------------------------------------------------------------------------------
# Autor: Treius
# Fecha: 20/10/2023
#
# Descripción: A partir de un archivo yaml que leeremos con python, el servidor maestro instalará los servicios apache y /o
#              php dependiendo del yaml.
#              En caso de que el servidor destino se encuentre en apache, se le instalará apache. En caso de que el servidor 
#              destino se encuentre en php, se le instalará php y apache.
#              Si el servidor destino se cambia a apache, se le deberán de borrar el paquete y sus dependencias php.
#----------------------------------------------------------------------------------------------------------------------------

# Funciones -----------------------------------------------------------------------------------------------------------------
apache_check () {
    ssh usuario@$1 'dpkg -l | grep apache2'
    if [ $? -eq 1 ]; then
        ssh usuario@$1 'sudo apt update -y'
        ssh usuario@$1 'sudo apt install -y apache2'
    fi
    ssh usuario@$i 'dpkg -l | grep php'                                                      # Los equipos de la lista apache no necesitan php0
    if [ $? -eq 0 ]; then
        ssh usuario@$1 "sudo apt purge -y 'php*' 'libapache2-mod-php*'"
        ssh usuario@$1 "sudo apt purge -y 'apache2*'"                                        # Por si acaso se desinstala apache ya que puede tener configs de php
        ssh usuario@$1 'sudo apt autoremove -y'
        ssh usuario@$1 'sudo apt install -y apache2'
    fi
}
php_check () {
    ssh usuario@$1 'dpkg -l | grep apache2' 
    if [ $? -eq 1 ]; then
        ssh usuario@$1 'sudo apt update -y'
        ssh usuario@$1 'sudo apt install -y apache2'
    fi
    ssh usuario@$i 'dpkg -l | grep php'
    if [ $? -eq 1 ]; then
        ssh usuario@$1 'sudo apt update -y'
        ssh usuario@$1 'sudo apt install -y php'
    fi
}

# Variables -----------------------------------------------------------------------------------------------------------------
lista_apache="$(python apache-deploy.py)"
lista_php="$(python php-deploy.py)"
log="./apache+php-deploy.log"

# Iniciamos log -------------------------------------------------------------------------------------------------------------
touch apache+php-deploy.log
echo $(date) >> $log

# Comprobar servicios instalados en la lista apache -------------------------------------------------------------------------
for ip in $lista_apache
do
    apache_check "$ip" &>> $log
done

# Comprobar servicios instalados en la lista php ----------------------------------------------------------------------------
for ip in $lista_php
do
    php_check "$ip" &>> $log
done
