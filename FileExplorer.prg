// Program : Switch FileExplorer //
// Author : Rubén Hernández Toboso //
//---------------------------------//

import "libmod_gfx";
import "libmod_input";
import "libmod_misc";
import "libmod_sound";
import "libmod_debug";

global
    int dir;  // identificador para diropen
    string fichero; // string con el que se imprimirán los nombres de los ficheros y carpetas
    int rect_seleccion; // identificador del rectángulo de selección
    int cont; // contador para las líneas de los ficheros y carpetas
	int contmount; // contador para las unidades disponibles
    int id_col; // identificador de la colisión
    int txt_file1; // identificador del texto 
    int txt_file2; // identificador del texto 
    int filename_length;
    int extension_length = 4;
    string extension;
	int skin;
    
local
    string filename; // string donde se guardará el nombre del fichero seleccionado
	int mount; // 0 sdmc 1 nand 2 romfs

	
process write_files(double x, y, string filename);
begin
    graph = write_in_map(0, filename, 6);
    say(filename);
    loop
        frame;
    end
end


process write_mount();
begin
     write(0,80,50,3,"sdmc:/");
	 write(0,80,60,3,"romfs:/");
     say("UNIDADES : "+mount);
     loop
         frame;
    end
end


process select_mount(double x, y);
begin
    signal(type select_files,s_kill);
    
	graph = rect_seleccion;
	y = 50;
	loop
	 switch(mount)
		       case 0:
			       say("sdmc");
			        if (joy_query(0, JOY_BUTTON_A)); 
                        while(joy_query(0, JOY_BUTTON_A));frame;end
                        chdir("sdmc:/");
					    main();
                    end         
               end
               case 1:
                   say("romfs");
				         if (joy_query(0, JOY_BUTTON_A)); 
                        while(joy_query(0, JOY_BUTTON_A));frame;end
                        chdir("romfs:/");
					    main();

                    end	
			   end
		end	   
			   
	     if (joy_query(0, JOY_BUTTON_DPAD_DOWN))
            while (joy_query(0, JOY_BUTTON_DPAD_DOWN)); frame; end;
            y = y + 10;
			mount = mount +1;
				//if(mount>0);
        end
        
        if (joy_query(0, JOY_BUTTON_DPAD_UP))
            while (joy_query(0, JOY_BUTTON_DPAD_UP)); frame; end;
            y = y - 10;
			mount = mount-1;
        end
		
		if(mount>1)
		y=60;
		end
		if(mount<1)
		y=50;
		end
		
	    frame;
     end      			   
end

process select_files(double x, y, string filename);
private
    int mp3;
	int png;
	int fpg;
	
begin
    signal(type select_mount,s_kill);
	background.graph = skin;
    graph = rect_seleccion;
    Y = 15;
   // txt_file1 = write(0, 100, 400, 4, "Nombre fichero : ");
	
    loop

        if (joy_query(0, JOY_BUTTON_DPAD_DOWN))
            while (joy_query(0, JOY_BUTTON_DPAD_DOWN)); frame; end;
            y = y + 10;
        end
        
        if (joy_query(0, JOY_BUTTON_DPAD_UP))
            while (joy_query(0, JOY_BUTTON_DPAD_UP)); frame; end;
            y = y - 10;
        end
        
        if (y <= 4)    
            y = 4;
        end
        
        if (y >= cont * 10)
            y = cont * 10 - 5;
        end
		
		if (joy_query(0, JOY_BUTTON_DPAD_LEFT))
		    while (joy_query(0, JOY_BUTTON_DPAD_LEFT)); frame; end
			graph=0;
			select_mount(100,45);
		end
        if (id_col = collision(type write_files))
//            txt_file1 = write(0, 100, 400, 4, "Nombre fichero : ");
            if ( txt_file2 ) write_delete(txt_file2); end
            //txt_file2 = write(0, 200, 400, 4, id_col.filename);
            filename_length = strlen(id_col.filename);
			

          //  say("cadena : "+filename_length);
            // DETECTA EL TIPO DE ARCHIVO O CARPETA
            if (id_col.filename != "")
                if (joy_query(0, JOY_BUTTON_A)); 
                    while(joy_query(0, JOY_BUTTON_A));frame;end
                    chdir(id_col.filename);
					main();
                end        
            end					
            filename_length = strlen(id_col.filename);
            if (filename_length >= extension_length)
                extension = substr(id_col.filename, filename_length - extension_length, extension_length);
                if (extension == ".mp3")
                    if (joy_query(0, JOY_BUTTON_B));
                        while(joy_query(0, JOY_BUTTON_B));frame;end
                        mp3 = music_load(id_col.filename);
                        music_play(mp3, -1);
                        say("Reproduciendo MP3!!");
                    end
                end
			  if (extension == ".png")
                    if (joy_query(0, JOY_BUTTON_B));
                        while(joy_query(0, JOY_BUTTON_B));frame;end
						write_delete(all_text);
                        png = map_load(id_col.filename);
                        background.graph=png;
                        say("Mostrando PNG!!");
						all_dead();
						signal(type select_files,s_kill);
						signal(type select_mount,s_kill);
						signal(type write_files,s_kill);
						signal(type list_files,s_kill);
                    end
                end
            end
			  if (extension == ".mp3")
                    if (joy_query(0, JOY_BUTTON_X)); 
                        while(joy_query(0, JOY_BUTTON_X));frame;end
                        music_stop();
			            music_unload(mp3);
            end
		end	
		
			        if (joy_query(0, JOY_BUTTON_X)); 
                        while(joy_query(0, JOY_BUTTON_X));frame;end
                        background.graph=skin;
			            map_unload(0,png);
		               
		end	  
			 if (joy_query(0, JOY_BUTTON_START)); 
                while(joy_query(0, JOY_BUTTON_START));frame;end
				fcopia("romfs:/data/Skins/default/main.png","sdmc:/main2.png");
                exit("Exiting...",0);
            end
        end

        frame;
    end

end


process list_files();
begin
    cont = 2;
	contmount = 5;
    write_delete(all_text);
    dir = diropen("*");
    if (dir != NULL)
	end
        fichero = dirread(dir);   
        while (fichero != "")
            write_files(220, cont * 10, fichero);
            cont = cont + 1; 
            fichero = dirread(dir);
        end
    loop
        frame;
    end
end    

process selection();
begin
    loop
     if (joy_query(0, JOY_BUTTON_DPAD_RIGHT))
            while (joy_query(0, JOY_BUTTON_DPAD_RIGHT)); frame; end;
            select_files(250, cont*10, fichero);
        end
	 if (joy_query(0, JOY_BUTTON_DPAD_LEFT))
            while (joy_query(0, JOY_BUTTON_DPAD_LEFT)); frame; end;
            select_mount(100,45);
        end	
        frame;
     end
end		

// COPY FILES //
function fcopia(string origen, string destino)
    private
        int pfich,pfich2;
        byte dato;
    end
    begin
        pfich=fopen(origen,0);
        pfich2=fopen(destino,2);
        
        repeat
            fread(pfich,dato);
            fwrite(pfich2,dato);
        until(feof(pfich));
		fclose(pfich);
		fclose(pfich2);
    end

function all_dead();
begin
say("ALL DEAD IN ACTION!");
	loop
	 if (joy_query(0, JOY_BUTTON_X))
            while (joy_query(0, JOY_BUTTON_X)); frame; end;
            main();
        end	
		frame;
	end
end	
	
// MAIN PROCESS
//---------------------------------------------------------
process main();
begin
    let_me_alone();
    set_mode(640, 480);
	
	selection();
	skin = map_load("romfs:/data/Skins/default/main.png");
	rect_seleccion = map_load("romfs:/data/selector.png");
    list_files();
    select_files(250, cont*10, fichero);
	write_mount();
    loop
	
        frame;
    end
end
