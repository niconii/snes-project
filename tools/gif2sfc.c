#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <gif_lib.h>

typedef unsigned char byte;

typedef enum Result {
    R_OK,

    R_ERR_INPUT_OPEN_FAILED,
    R_ERR_INPUT_READ_FAILED,
    R_ERR_INPUT_CLOSE_FAILED,

    R_ERR_OUTPUT_OPEN_FAILED,
    R_ERR_OUTPUT_WRITE_FAILED,
    R_ERR_OUTPUT_CLOSE_FAILED,

    R_ERR_GIF_NO_GLOBAL_COLOR_MAP,
    R_ERR_GIF_FRAME_COUNT_NOT_1,
    R_ERR_GIF_LOCAL_COLOR_MAP,

    R_ERR_IMAGE_BAD_BPP,
    R_ERR_IMAGE_BAD_SIZE,
} Result;

char *Result_to_s(Result result) {
    switch (result) {
    case R_OK:
        return "No error";

    case R_ERR_INPUT_OPEN_FAILED:
        return "Failed to open input file";
    case R_ERR_INPUT_READ_FAILED:
        return "Failed to read input file";
    case R_ERR_INPUT_CLOSE_FAILED:
        return "Failed to close input file";

    case R_ERR_OUTPUT_OPEN_FAILED:
        return "Failed to open output file";
    case R_ERR_OUTPUT_WRITE_FAILED:
        return "Failed to write output file";
    case R_ERR_OUTPUT_CLOSE_FAILED:
        return "Failed to close output file";

    case R_ERR_GIF_NO_GLOBAL_COLOR_MAP:
        return "GIF has no global color map";
    case R_ERR_GIF_FRAME_COUNT_NOT_1:
        return "GIF frame count must be 1";
    case R_ERR_GIF_LOCAL_COLOR_MAP:
        return "GIF frame must not have local color map";

    case R_ERR_IMAGE_BAD_BPP:
        return "Only 2bpp, 4bpp, or 8bpp supported";
    case R_ERR_IMAGE_BAD_SIZE:
        return "Image dimensions must be multiples of 8";

    default:
        return "Unknown error";
    }
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

Result Image_new(GifFileType *gif, Image *image) {
    ColorMapObject *color_map = gif->SColorMap;
    if (!color_map)
        return R_ERR_GIF_NO_GLOBAL_COLOR_MAP;
    if (gif->ImageCount != 1)
        return R_ERR_GIF_FRAME_COUNT_NOT_1;

    SavedImage *frame = &gif->SavedImages[0];
    if (frame->ImageDesc.ColorMap)
        return R_ERR_GIF_LOCAL_COLOR_MAP;

    image->width = gif->SWidth;
    image->height = gif->SHeight;
    int pixels_size = gif->SWidth * gif->SHeight;

    image->pixels = malloc(pixels_size);
    memset(image->pixels, gif->SBackGroundColor, pixels_size);

    GifImageDesc *d = &frame->ImageDesc;
    for (int y = 0; y < d->Height; y++) {
        for (int x = 0; x < d->Width; x++) {
            int fi = d->Width*y + x;

            int py = y + d->Top;
            int px = x + d->Left;
            int pi = image->width*py + px;

            image->pixels[pi] = frame->RasterBits[fi];
        }
    }

    return R_OK;
}

void Image_free(Image *image) {
    free(image->pixels);
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

Result Image_to_planar(Image *image, int bpp, Bytes *tiles) {
    if (bpp != 2 && bpp != 4 && bpp != 8)
        return R_ERR_IMAGE_BAD_BPP;
    if (image->width % 8 || image->height % 8)
        return R_ERR_IMAGE_BAD_SIZE;

    int tile_w = image->width / 8;
    int tile_h = image->height / 8;

    tiles->size = image->width * image->height * bpp / 8;
    tiles->data = malloc(tiles->size);
    byte *out = tiles->data;

    for (int y = 0; y < image->height; y += 8) {
        for (int x = 0; x < image->width; x += 8) {
            byte *tile = &image->pixels[image->width*y + x];
            for (int i = 0; i < bpp/2; i++) {
                convert_2bpp(&out, tile, image->width);
            }
        }
    }

    return R_OK;
}

Result go(char *in_name, char *out_name, int bpp) {
    Result result;

    GifFileType *gif = DGifOpenFileName(in_name, NULL);
    if (!gif)
        return R_ERR_INPUT_OPEN_FAILED;
    if (!DGifSlurp(gif))
        return R_ERR_INPUT_READ_FAILED;

    Image image;
    result = Image_new(gif, &image);
    if (result != R_OK)
        return result;
    
    if (!DGifCloseFile(gif, NULL))
        return R_ERR_INPUT_CLOSE_FAILED;

    Bytes tiles;
    result = Image_to_planar(&image, bpp, &tiles);
    if (result != R_OK)
        return result;

    FILE *out = fopen(out_name, "wb");
    if (!out)
        return R_ERR_OUTPUT_OPEN_FAILED;
    if (!fwrite(tiles.data, tiles.size, sizeof(byte), out))
        return R_ERR_OUTPUT_WRITE_FAILED;
    if (fclose(out))
        return R_ERR_OUTPUT_CLOSE_FAILED;

    free(tiles.data);

    return R_OK;
}

int main(int argc, char *argv[]) {
    char *name = argc > 0 ? argv[0] : "gif2sfc";
    if (argc != 4) {
        fprintf(stderr, "Usage: %s bpp input.gif output\n", name);
        return 1;
    }

    int bpp = atoi(argv[1]);
    char *in_name = argv[2];
    char *out_name = argv[3];

    Result result = go(in_name, out_name, bpp);
    if (result != R_OK) {
        fprintf(stderr, "%s: %s", name, Result_to_s(result));
        if (errno)
            fprintf(stderr, ": %s\n", strerror(errno));
        else
            fprintf(stderr, "\n");

        return 1;
    }

    return 0;
}
