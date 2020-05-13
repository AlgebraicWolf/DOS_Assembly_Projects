tasm /la box_int.asm
tasm /la boxlib.asm
tlink /t box_int.obj boxlib.obj
@move box_int.com program.com