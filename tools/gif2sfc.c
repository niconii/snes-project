#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <gif_lib.h>

char *program_name = "gif2sfc";

typedef unsigned char byte;

void die(char *msg) {
    fprintf(stderr, "%s: %s", program_name, msg);
    if (errno)
        fprintf(stderr, ": %s\n", strerror(errno));
    else
        fprintf(stderr, "\n");
    exit(1);
}

typedef struct Bytes {
    int size;
    byte *data;
} Bytes;

typedef struct Image {
    int width;
    int height;
    byte *pixels;
} Image;

Image Image_new(GifFileType *gif) {
    ColorMapObject *color_map = gif->SColorMap;
    if (!color_map)
        die("GIF missing global color map");
    if (gif->ImageCount != 1)
        die("GIF frame count must be 1");

    SavedImage *frame = &gif->SavedImages[0];
    if (frame->ImageDesc.ColorMap)
        die("GIF frame must not have local color map");

    int pixels_size = gif->SWidth * gif->SHeight;
    Image image = {gif->SWidth, gif->SHeight, malloc(pixels_size)};
    memset(image.pixels, gif->SBackGroundColor, pixels_size);

    GifImageDesc *d = &frame->ImageDesc;
    for (int y = 0; y < d->Height; y++) {
        for (int x = 0; x < d->Width; x++) {
            int fi = d->Width*y + x;

            int py = y + d->Top;
            int px = x + d->Left;
            int pi = image.width*py + px;

            image.pixels[pi] = frame->RasterBits[fi];
        }
    }

    return image;
}

void Image_free(Image image) {
    free(image.pixels);
}

void convert_2bpp(byte **out, byte *tile, int stride) {
    for (int y = 0; y < 8; y++) {
        byte *row = &tile[stride*y];
        byte plane0 = 0;
        byte plane1 = 0;
        for (int x = 0; x < 8; x++) {
            plane0 |= (row[x] & 1) << (7 - x);
            row[x] >>= 1;
            plane1 |= (row[x] & 1) << (7 - x);
            row[x] >>= 1;
        }
        *(*out)++ = plane0;
        *(*out)++ = plane1;
    }
}

Bytes Image_to_planar(Image image, int bpp) {
    if (bpp != 2 && bpp != 4 && bpp != 8)
        die("Only 2bpp, 4bpp, or 8bpp supported");
    if (image.width % 8 || image.height % 8)
        die("Image dimensions must be multiples of 8");

    int size = image.width * image.height * bpp / 8;
    byte *bytes = malloc(size);
    byte *out = bytes;

    for (int y = 0; y < image.height; y += 8) {
        for (int x = 0; x < image.width; x += 8) {
            byte *tile = &image.pixels[image.width*y + x];
            for (int i = 0; i < bpp/2; i++) {
                convert_2bpp(&out, tile, image.width);
            }
        }
    }

    Bytes tiles = {size, bytes};
    return tiles;
}

int main(int argc, char *argv[]) {
    if (argc > 0)
        program_name = argv[0];

    if (argc != 4) {
        fprintf(stderr, "Usage: %s bpp input.gif output\n", program_name);
        return 1;
    }

    int bpp = atoi(argv[1]);
    char *in_name = argv[2];
    char *out_name = argv[3];

    GifFileType *gif = DGifOpenFileName(in_name, NULL);
    if (!gif)
        die("Failed to open input file");
    if (!DGifSlurp(gif))
        die("Failed to read input file");

    Image image = Image_new(gif);

    if (!DGifCloseFile(gif, NULL))
        die("Failed to close input file");

    Bytes tiles = Image_to_planar(image, bpp);

    FILE *out = fopen(out_name, "wb");
    if (!out)
        die("Failed to open output file");
    if (!fwrite(tiles.data, tiles.size, sizeof(byte), out))
        die("Failed to write output file");
    if (fclose(out))
        die("Failed to close output file");

    free(tiles.data);

    return 0;
}
