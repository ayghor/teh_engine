#include "assets.h"

/*
 * hashing
 *
 */
static const unsigned char T[256] =
{
	251, 175, 119, 215, 81, 14, 79, 191, 103, 49, 181, 143, 186, 157, 0,
	232, 31, 32, 55, 60, 152, 58, 17, 237, 174, 70, 160, 144, 220, 90, 57,
	223, 59, 3, 18, 140, 111, 166, 203, 196, 134, 243, 124, 95, 222, 179,
	197, 65, 180, 48, 36, 15, 107, 46, 233, 130, 165, 30, 123, 161, 209, 23,
	97, 16, 40, 91, 219, 61, 100, 10, 210, 109, 250, 127, 22, 138, 29, 108,
	244, 67, 207, 9, 178, 204, 74, 98, 126, 249, 167, 116, 34, 77, 193,
	200, 121, 5, 20, 113, 71, 35, 128, 13, 182, 94, 25, 226, 227, 199, 75,
	27, 41, 245, 230, 224, 43, 225, 177, 26, 155, 150, 212, 142, 218, 115,
	241, 73, 88, 105, 39, 114, 62, 255, 192, 201, 145, 214, 168, 158, 221,
	148, 154, 122, 12, 84, 82, 163, 44, 139, 228, 236, 205, 242, 217, 11,
	187, 146, 159, 64, 86, 239, 195, 42, 106, 198, 118, 112, 184, 172, 87,
	2, 173, 117, 176, 229, 247, 253, 137, 185, 99, 164, 102, 147, 45, 66,
	231, 52, 141, 211, 194, 206, 246, 238, 56, 110, 78, 248, 63, 240, 189,
	93, 92, 51, 53, 183, 19, 171, 72, 50, 33, 104, 101, 69, 8, 252, 83, 120,
	76, 135, 85, 54, 202, 125, 188, 213, 96, 235, 136, 208, 162, 129, 190,
	132, 156, 38, 47, 1, 7, 254, 24, 4, 216, 131, 89, 21, 28, 133, 37, 153,
	149, 80, 170, 68, 6, 169, 234, 151,
};

static inline unsigned pearsons_hash(const char* x)
{
	int i;
	unsigned h;

	h = 0;
	for (i = 0; x[i]; ++i)
		h = T[h ^ x[i]];

	return h;
}

/*
 * hash table
 *
 */
struct row
{
	const char* path;
	void* stuff;
	struct row* next;
};

static struct row* table[256];

static inline struct row** seek(const char* path)
{
	struct row** pr;

	for (pr = &table[pearsons_hash(path)]; (*pr); pr = &(*pr)->next)
		if (strcmp(path, (*pr)->path) == 0)
			break;

	return pr;
}

static inline void* get(const char* path)
{
	struct row** pr;
	pr = seek(path);
	return (*pr) ? (*pr)->stuff : NULL; 
}

static inline void set(const char* path, void* stuff)
{
	struct row** pr;
	pr = seek(path);

	if (!(*pr))
	{
		(*pr) = calloc(1, sizeof (struct row));
		(*pr)->path = path;
	}

	(*pr)->stuff = stuff;
}

/*
 * type loaders
 *
 */
struct teh* teh_get(const char* path)
{
	struct teh* model;

	model = get(path);

	if (!model)
	{
		model = calloc(1, sizeof (struct teh));
		teh_read_file(model, path);
		set(path, model);
	}

	return model;
}

struct beh* beh_get(const char* path)
{
	struct beh* bsp;

	bsp = get(path);

	if (!bsp)
	{
		bsp = calloc(1, sizeof (struct beh));
		beh_read_file(bsp, path);
		set(path, bsp);
	}

	return bsp;
}

struct SDL_Surface* image_get(const char* path)
{
	SDL_Surface* surf;

	surf = get(path);

	if (!surf)
	{
		surf = IMG_Load(path);
		set(path, surf);
	}

	return surf;
}
