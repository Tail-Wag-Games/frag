#include <stdio.h>

typedef struct Vec2f_t {
    float x;
    float y;
} Vec2f;

extern void window_size(Vec2f * size);

int main(void)
{
  NimMain();

  Vec2f size = { 0.0f, 0.0f };
  window_size(&size);
  printf("window size is x: %f, y: %f\n", size.x, size.y);
  return 0;
}