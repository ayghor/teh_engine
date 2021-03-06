#
# TEH_ENGINE MAKEFIEL!!1!11ONE!
#

#
# configs
#

# compiler
CC := gcc
CFLAGS := \
	-Isauce \
	`pkg-config sdl2 --cflags` \
	`pkg-config SDL2_image --cflags` \
	`pkg-config SDL2_mixer --cflags` \
	`pkg-config check --cflags` \
	`pkg-config libgvc --cflags` \
	`pkg-config glesv2 --cflags` \
	-std=c99 \
	-Wall \
	-pipe \
	-ggdb \
	-DOPENGL_ES \
	$(CFLAGS)

# linker
LD := gcc
LDFLAGS := \
	-lm \
	`pkg-config sdl2 --libs` \
	`pkg-config SDL2_image --libs` \
	`pkg-config SDL2_mixer --libs` \
	`pkg-config check --libs` \
	`pkg-config libgvc --libs` \
	`pkg-config glesv2 --libs` \
	$(LDFLAGS)

#
# target lists
#
SHADERS := \
	build/r_fragment_shader.glsl.c \
	build/r_vertex_shader.glsl.c

LIB_OBJS := \
	build/teh.o \
	build/vec.o \
	build/assets.o \
	build/beh.o \
	build/poly.o \
	build/pool.o \
	build/box.o \
	build/trace.o \

GUI_OBJS := \
	build/window.o \
	build/r_fragment_shader.glsl.o \
	build/r_vertex_shader.glsl.o \
	build/renderer.o \
	build/controller.o \
	build/r_teh.o \
	build/r_beh.o \

BSPC_OBJS := \
	build/tri.o \
	build/bspc.o \

CHECK_OBJS := \
	build/check/check.o \
	build/check/check_poly.o \
	build/check/check_tri_split.o \
	build/check/check_bspc.o \
	build/check/check_pool.o \
	build/check/check_box.o \

OBJS := \
	$(LIB_OBJS) \
	$(GUI_OBJS) \
	$(BSPC_OBJS) \
	$(CHECK_OBJS) \
	build/check/check.o \
	build/behc.o \
	build/engine.o \

PRGS := \
	build/check/check \
	build/behc \
	build/engine

TEHS := \
	tehs/blorl.teh \
	tehs/crossing_quads.teh \
	tehs/igualomagic.teh \
	tehs/igualomapa.teh \
	tehs/igualopeople.teh \
	tehs/parallel_quads.teh \
	tehs/zoing.teh \
	tehs/boxxy.teh \

BEHS := \
	behs/blorl.beh \
	behs/crossing_quads.beh \
	behs/igualomagic.beh \
	behs/igualomapa.beh \
	behs/parallel_quads.beh \
	behs/zoing.beh \
	#behs/igualopeople.beh

ALL_FILES := \
	$(SHADERS) \
	$(OBJS) \
	$(PRGS) \
	$(TEHS) \
	$(BEHS) \

#
# recipes
#

# all and clean
.PHONY: all clean check
all: $(PRGS)

clean:
	rm -f $(SHADERS) $(OBJS) $(PRGS)

clean_all:
	rm -f $(ALL_FILES)

check: build/check/check
	$^

tehs: $(TEHS)
behs: $(BEHS)

# exporta modelos
tehs/%.teh: blends/%.blend
	mkdir -p `dirname $@`
	blender $< -b -P sauce/teh_export_cli.py -- $@

# compila mapas
behs/%.beh: tehs/%.teh build/behc
	mkdir -p `dirname $@`
	build/behc $< $@

# shaders
build/%.glsl.c: sauce/%.glsl
	mkdir -p `dirname $@`
	cp $< .
	xxd -i `basename $<` $@
	rm `basename $<`

# state machines
build/%.rl.c: sauce/%.rl
	mkdir -p `dirname $@`
	$(RAGEL) $(RLFLAGS) -o $@ $<

# objs
build/%.o: sauce/%.c
	mkdir -p `dirname $@`
	$(CC) $(CFLAGS) -o $@ -c $<

# prgs
build/behc: build/behc.o $(BSPC_OBJS) $(LIB_OBJS)
build/engine: build/engine.o $(LIB_OBJS) $(GUI_OBJS)
build/check/check: build/check/check.o $(CHECK_OBJS) $(BSPC_OBJS) $(LIB_OBJS) $(GUI_OBJS)
	mkdir -p `dirname $@`
	$(LD) $(LDFLAGS) -o $@ $^
