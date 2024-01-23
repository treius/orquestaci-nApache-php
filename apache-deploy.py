#-------------------------------------------------------------
# Autor: Treius
# Fecha: 20/10/2023
#
# Descripción: A partir de un archivo yaml lee la clase de 
#              objetos apache e imprime el valor del atributo 
#              ip de cada objeto.
#-------------------------------------------------------------

import yaml
from yaml.loader import SafeLoader

with open('servers.yaml') as f:
    data=yaml.load(f, Loader=SafeLoader)
    # Imprimir direcciones IP de Apache
    for apache in data['apache']:
        print(apache['ip'])
