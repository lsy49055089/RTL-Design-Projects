#ifndef HAL_MMIO_H
#define HAL_MMIO_H

#include "xil_io.h"
#include "xil_types.h"

static inline u32 hal_read32(u32 base, u32 offset)
{
    return Xil_In32(base + offset);
}

static inline void hal_write32(u32 base, u32 offset, u32 value)
{
    Xil_Out32(base + offset, value);
}

#endif
