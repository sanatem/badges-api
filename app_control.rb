#El archivo contiene lo necesario para ejecutar la app como un daemon/servicio.

require 'rubygems'
require 'daemons'

#Definir el path donde está situada la app.
path="/home/ciencia/projects/badges/badges-api"

Daemons.run_proc('app/app.rb',:dir=>path) do
	Dir.chdir(path)
	exec "rackup -o 163.10.5.42"
end
