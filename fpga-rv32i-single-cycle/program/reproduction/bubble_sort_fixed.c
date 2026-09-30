/* Reproduction program added after the original coursework submission.
 * Data RAM is 256 bytes. Words at byte addresses 16..32 hold the result.
 * The stack starts at byte address 256 (see start.S).
 */
static void swap(int *a, int *b)
{
    int temporary = *a;
    *a = *b;
    *b = temporary;
}

static void sort(int *values, int count)
{
    for (int i = 0; i < count - 1; ++i) {
        for (int j = 0; j < count - i - 1; ++j) {
            if (values[j] > values[j + 1]) {
                swap(&values[j], &values[j + 1]);
            }
        }
    }
}

int main(void)
{
    /* Explicit stores avoid a .rodata section: this CPU has separate small
     * instruction and data memories and no startup code to copy constants.
     */
    int values[5];
    values[0] = 3;
    values[1] = 5;
    values[2] = 9;
    values[3] = 1;
    values[4] = 7;
    const int count = sizeof(values) / sizeof(values[0]);
    volatile int *output = (volatile int *)16;
    sort(values, count);
    for (int i = 0; i < count; ++i) {
        output[i] = values[i];
    }
    return 0;
}
