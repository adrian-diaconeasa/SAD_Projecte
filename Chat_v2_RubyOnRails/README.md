

Esta segunda parte del proyecto ha sido para profundizar más en el entorno de R
uby, el código implementado es una mezcla de información extraída de foros y contenido nuestro.

Para editar el código hemos utilizado Atom

Hemos empleado las siguientes versiones de ruby y rails:

	- Ruby 2.6.3p62
	- Rails 6.1.3.2

Para crear un proyecto vacío:

	rails new NombreProyecto

Antes de empezar, lo primero que tenemos que hacer es descomprimir la carpeta:

	node_modules.zip

Para inicializar el servidor, debemos utilizar el comando:

	rails s

Para instalar las gemas, comando:

	bundle install

Para eliminar la base de datos del chat:

	rake db:reset db:migrate
