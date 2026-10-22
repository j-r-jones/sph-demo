CC=mpicc

LDFLAGS+=-L$(SDKSTAGE)/opt/vc/lib/ -lGLESv2 -lGLEW -lEGL -lopenmaxil -lbcm_host -lvcos -lvchiq_arm -lpthread -lrt -L../libs/ilclient -L../libs/vgfont -lfreetype
INCLUDES+=-I$(SDKSTAGE)/opt/vc/include/ -I$(SDKSTAGE)/opt/vc/include/interface/vcos/pthreads -I$(SDKSTAGE)/opt/vc/include/interface/vmcs_host/linux -I./ -I../libs/ilclient -I../libs/vgfont -I/usr/include/freetype2 -I./blink1
CFLAGS= -DRASPI -mfloat-abi=hard -mfpu=vfp -O3 -lm -ffast-math -g

all:
	mkdir -p bin
	$(CC) $(CFLAGS) $(INCLUDES) $(LDFLAGS) ogl_utils.c egl_utils.c dividers_gl.c liquid_gl.c exit_menu_gl.c image_gl.c cursor_gl.c rectangle_gl.c lodepng.c background_gl.c font_gl.c particles_gl.c mover_gl.c controls.c renderer.c geometry.c hash.c communication.c fluid.c -o bin/sph

light:
	mkdir -p bin
	$(CC) $(CFLAGS) $(INCLUDES) $(LDFLAGS) -DLIGHT ogl_utils.c egl_utils.c rgb_light.c dividers_gl.c liquid_gl.c exit_menu_gl.c image_gl.c cursor_gl.c rectangle_gl.c lodepng.c background_gl.c font_gl.c particles_gl.c mover_gl.c controls.c renderer.c geometry.c hash.c communication.c fluid.c -o bin/sph

blink:
	mkdir -p bin
	cd blink1 && make
	mkdir -p bin        
	$(CC) $(CFLAGS) $(INCLUDES) $(LDFLAGS) -DBLINK1 -L./blink1 -lblink1 ogl_utils.c egl_utils.c blink1_light.c dividers_gl.c liquid_gl.c exit_menu_gl.c image_gl.c cursor_gl.c rectangle_gl.c lodepng.c background_gl.c font_gl.c particles_gl.c mover_gl.c controls.c renderer.c geometry.c hash.c communication.c fluid.c -o bin/sph


clean:
	rm -f ./bin/sph
	rm -f ./*.o
	cd blink1 && make clean

run: copy
	cd $(HOME) ; mpirun -f ~/pi_mpihostsfile -n 9 ~/sph ; cd $(HOME)/SPH

copy:
	scp ./bin/sph pi1:~/
	scp ./bin/sph pi2:~/
	scp ./bin/sph pi3:~/
	scp ./bin/sph pi4:~/
	scp ./bin/sph pi5:~/
	scp ./bin/sph pi6:~/
	scp ./bin/sph pi7:~/
	scp ./bin/sph pi8:~/
	scp ./bin/sph pi9:~/
